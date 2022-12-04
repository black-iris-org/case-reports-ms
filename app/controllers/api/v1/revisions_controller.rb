class Api::V1::RevisionsController < ApplicationController
  before_action :set_case_report, only: [:index, :show]
  before_action :set_revision, only: [:show]
  before_action :set_revisions, only: [:index]

  def index
    render json: {
      case_report: CaseReportSerializer.render_as_hash(@case_report, view: :without_revision),
      revisions: RevisionSerializer.render_as_hash(@revisions)
    }
  end

  def show
    @case_report.set_custom_revision(@revision)
    render json: CaseReportSerializer.render(@case_report)
  end

  private

  def set_case_report
    @case_report = CaseReport.find(params[:case_report_id])
  end

  def set_revision
    @revision = @case_report.revisions.find(params[:id])
  end

  def set_revisions
    @revisions = @case_report.revisions
  end
end
