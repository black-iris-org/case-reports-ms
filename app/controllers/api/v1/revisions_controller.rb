class Api::V1::RevisionsController < ApplicationController
  include FiltrationConcern
  include AuditsConcern
  include PaginationConcern

  before_action :set_case_reports, only: [:index, :show]
  before_action :set_case_report, only: [:index, :show]
  before_action :set_revisions, only: [:index, :show]
  before_action :set_user_filter, only: [:index, :show]
  before_action :set_revision, only: [:show]
  before_action :set_audit_additional_data, only: [:show], unless: :skip_audit?

  def index
    render json: V1::CaseReportSerializer.render(
      @case_report,
      root: :case_report,
      revisions: paginate(@revisions),
      meta: pagination_status,
      view: :with_custom_revisions
    )
  end

  private

  def set_case_reports
    @case_reports = CaseReport.filter_records(filtration_params)
  end

  def set_case_report
    return if @case_report.present?

    @case_report = @case_reports.find(params[:case_report_id]) if params[:case_report_id].present?
  end

  def set_revisions
    if @case_report.present?
      @revisions = @case_report.revisions.reverse
    else
      # Backward compatibility - empty array instead of all revisions
      @revisions = []
    end
  end

  def set_revision
    @case_report = if skip_audit?
                     @case_report.revision(params[:id].to_i)
                   else
                     @case_reports.with_show_auditing { @case_report.revision(params[:id].to_i) }
                   end
  end

  def set_user_filter
    return unless params[:user_id].present?

    @revisions = @revisions.where(user_id: params[:user_id])
  end

  def option_params
    params.permit(:view).allow(view: %w[full_details])
  end

  def filtration_params
    filters      = default_filtration_params
    filters[:id] = params[:case_report_id] if params[:case_report_id].present?
    filters
  end
end
