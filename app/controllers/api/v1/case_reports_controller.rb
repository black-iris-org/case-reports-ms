class Api::V1::CaseReportsController < ApplicationController
  include AuditsConcern
  include PaginationConcern
  include FiltrationConcern

  before_action :set_case_reports, only: [:show, :update, :index, :incidents]
  before_action :set_case_report, only: [:show, :update]
  after_action :add_audit_record, only: [:create, :show, :update]

  def index
    render json: CaseReportSerializer.render(paginate(@case_reports), root: :case_reports, meta: pagination_status)
  end

  def create
    @case_report = CaseReport.create!(create_params)
    @revision_id = @case_report.revision_id
    render json: CaseReportSerializer.render(@case_report, root: :case_report)
  end

  def update
    @case_report.update!(update_params)
    @revision_id = @case_report.revision_id
    render json: CaseReportSerializer.render(@case_report.reload, root: :case_report)
  end

  def show
    render json: CaseReportSerializer.render(@case_report, root: :case_report)
  end

  def incidents
    @case_reports = CaseReport.filter_records(default_filtration_params_with_incident)
    render json: CaseReportSerializer.render(@case_reports, root: :case_reports)
  end

  private

  def create_params
    case_report_create_params.merge(revisions_attributes: [revision_attributes])
  end

  def update_params
    params.permit(:case_report_name).merge({ revisions_attributes: [revision_attributes] })
  end

  def case_report_create_params
    params.require(:case_report).permit(:incident_number, :case_report_name, :incident_id).merge(datacenter_id: requester_datacenter)
  end

  def revision_attributes
    params.permit(Revision::PRIMITIVE_COLUMNS.dup << Revision::JSONB_COLUMNS).merge(user_id: requester_id)
  end

  def set_case_report
    @case_report = @case_reports.find(params[:id])
    @revision_id = @case_report.revision_id
  end

  def set_case_reports
    @case_reports = CaseReport.filter_records(default_filtration_params)
  end
end
