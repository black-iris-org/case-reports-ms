class Api::V1::RevisionsController < ApplicationController
  include FiltrationConcern
  include AuditsConcern
  include PaginationConcern

  before_action :set_case_reports, only: [:index, :show]
  before_action :set_case_report, only: [:index, :show]
  before_action :set_revisions, only: [:index, :show]
  before_action :set_user_filter, only: [:index, :show]
  before_action :set_revision, only: [:show]
  after_action :add_audit_record, only: [:show]

  def index
    if @case_report.present?
      render json: CaseReportSerializer.render(
        @case_report,
        root: :case_report,
        view: :with_revisions,
        custom_revision_list: paginate(@case_report.revisions),
        meta: pagination_status
      )
    else
      render json: RevisionSerializer.render(
        paginate(@revisions),
        root: :revisions,
        view: :with_case_report,
        meta: pagination_status
      )
    end
  end

  def show
    @case_report.set_custom_revision(@revision)
    render json: CaseReportSerializer.render(@case_report, root: :case_report)
  end

  private

  def set_case_reports
    @case_reports = CaseReport.with_revision.filter_records(default_filtration_params)
  end

  def set_case_report
    return if @case_report.present?

    if @revision.present?
      @case_report = @revision.case_report
    elsif params[:case_report_id].present?
      @case_report = @case_reports.find(params[:case_report_id])
    end
  end

  def set_revisions
    if @case_report.present?
      @revisions = @case_report.revisions.with_case_report
    else
      @revisions = Revision.filter_records(default_filtration_params).with_case_report
    end
  end

  def set_revision
    @revision = @revisions.find(params[:id])
    @case_report = @revision.case_report if @case_report.blank?
    @revision_id = @revision.id
  end

  def set_user_filter
    return unless params[:user_id].present?

    @revisions = @revisions.where(user_id: params[:user_id])
  end
end
