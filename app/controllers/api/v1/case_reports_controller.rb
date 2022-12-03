class Api::V1::CaseReportsController < ApplicationController
  before_action :set_case_report, only: [:show, :update]
  before_action :set_case_reports, only: [:index]

  def index
    render json: CaseReportSerializer.render(@case_reports)
  end

  def create
    case_report = CaseReport.create!(create_params)
    render json: CaseReportSerializer.render(case_report)
  end

  def update
    @case_report.update!(update_params)
    render json: CaseReportSerializer.render(@case_report.reload)
  end

  def show
    render json: CaseReportSerializer.render(@case_report)
  end

  private

  def create_params
    case_report_create_params.merge(revisions_attributes: [revision_attributes])
  end

  def update_params
    { revisions_attributes: [revision_attributes] }
  end

  def case_report_create_params
    params.require(:case_report).permit(:incident_number)
  end

  def revision_attributes
    params.permit(Revision::REPORT_COLUMNS)
  end

  def set_case_report
    @case_report = CaseReport.find(params[:id])
  end

  def set_case_reports
    @case_reports = CaseReport.all
  end
end
