class Api::V1::AuditsController < ApplicationController
  include PaginationConcern

  include FiltrationConcern

  before_action :set_audits
  before_action :set_revision_filter

  def index
    render json: AuditSerializer.render(paginate(@audits), root: :audits, meta: pagination_status)
  end

  private

  def set_audits
    @audits = Audit.filter_records(filtration_params)
  end

  def set_revision_filter
    return unless params[:revision_id].present?

    @audits = @audits.where(revision_id: params[:revision_id])
  end

  def filtration_params
    default_filtration_params.merge(case_report_id: params[:case_report_id])
  end
end
