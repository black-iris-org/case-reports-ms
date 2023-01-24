class Api::V1::AuditsController < ApplicationController
  include PaginationConcern
  include FiltrationConcern

  before_action :set_audits

  def index
    render json: AuditSerializer.render(paginate(@audits), root: :audits, meta: pagination_status)
  end

  def create
    @audit = Audit.create!(audit_params)
    render json: AuditSerializer.render(@audit, root: :audit)
  end

  private

  def set_audits
    @audits = Audit.eager_load(:case_report).filter_records(filtration_params).order(id: :desc)
  end

  def audit_params
    params.require(:audit).permit(:revision_id, :action, :action_at).merge(enforced_audit_params)
  end

  def enforced_audit_params
    { user_name: requester_name, user_type: requester_role, user_id: requester_id }
  end

  def index_params
    params.permit(:case_report_id, :revision_id, :action_at, :action_time_from, :action_time_to, :user_id, :incident_number)
  end

  def filtration_params
    default_filtration_params.merge(index_params.to_h).compact
  end
end
