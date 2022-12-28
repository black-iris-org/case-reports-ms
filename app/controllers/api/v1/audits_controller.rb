class Api::V1::AuditsController < ApplicationController
  include PaginationConcern
  include FiltrationConcern

  before_action :set_audits

  def index
    render json: AuditSerializer.render(paginate(@audits), root: :audits, meta: pagination_status)
  end

  private

  def set_audits
    @audits = Audit.filter_records(filtration_params).order(id: :desc)
  end

  def index_params
    params.permit(:case_report_id, :revision_id, :action_at, :action_time_from, :action_time_to, :user_id)
  end

  def filtration_params
    default_filtration_params.merge(index_params.to_h).compact
  end
end
