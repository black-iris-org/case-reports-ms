class Api::V1::CaseReportsController < ApplicationController
  include AuditsConcern
  include PaginationConcern
  include FiltrationConcern

  before_action :set_case_reports, only: [:show, :update, :index]
  before_action :set_case_report, only: [:show, :update]
  after_action :add_audit_record, only: [:create, :show, :update]

  def index
    render json: CaseReportSerializer.render(paginate(@case_reports), root: :case_reports, meta: pagination_status)
  end

  def create
    @case_report = CaseReport.create!(create_params)
    @revision_id = @case_report.revision_id
    render json: CaseReportSerializer.render(@case_report, root: :case_report, **serializer_options)
  end

  def update
    if file_params_present?
      @case_report.update!(update_params)
    else
      previous_revision = @case_report.revision
      ActiveRecord::Base.transaction do
        @case_report.update!(update_params)
        @case_report.revision.files_blobs += previous_revision.files_blobs
      end
    end
    @revision_id = @case_report.revision_id
    render json: CaseReportSerializer.render(@case_report.reload, root: :case_report, **serializer_options)
  end

  def show
    render json: CaseReportSerializer.render(@case_report, root: :case_report)
  end

  private

  def create_params
    params.require(:case_report).permit(:incident_number, :incident_at, :incident_id).merge(
      datacenter_id: requester_datacenter,
      revisions_attributes: [revision_params]
    )
  end

  def update_params
    {
      datacenter_id: requester_datacenter,
      revisions_attributes: [revision_params]
    }
  end

  def revision_attributes
    attributes = (Revision::PRIMITIVE_COLUMNS.dup << Revision::JSONB_COLUMNS)
    attributes << { files_attributes: [:filename, :checksum, :byte_size, :content_type] }
  end

  def revision_params
    params.require(:case_report).permit(*revision_attributes).merge(user_id: requester_id)
  end

  def file_params_present?
    revision_params[:files_attributes].present?
  end

  def filters
    params.permit(:incident_id).merge(default_filtration_params)
  end

  def set_case_report
    @case_report = @case_reports.find(params[:id])
    @revision_id = @case_report.revision_id
  end

  def set_case_reports
    @case_reports = CaseReport.filter_records(filters.to_h).order(id: :desc)
  end

  def serializer_options
    { with_direct_upload_urls: file_params_present? }
  end
end
