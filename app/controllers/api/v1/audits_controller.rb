class Api::V1::AuditsController < ApplicationController
  include PaginationConcern
  include FiltrationConcern

  before_action :set_audits

  def index
    render json: AuditSerializer.render(paginate(@audits), root: :audits, meta: pagination_status)
  end

  private

  def set_audits
    @audits = Audit.filter_records(filtration_params)
  end

  def filtration_params
    filters = default_filtration_params
    filters[:case_report_id] = params[:case_report_id] if params[:case_report_id].present?
    filters[:revision_id] = params[:revision_id] if params[:revision_id].present?
    filters
  end
end
