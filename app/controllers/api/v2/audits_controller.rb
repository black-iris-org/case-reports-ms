class Api::V2::AuditsController < ApplicationController
  include PaginationConcern
  include FiltrationConcern

  before_action :set_audits

  def index
    render json: V2::AuditSerializer.render(paginate(@audits), root: :audits, meta: pagination_status)
  end

  def create
    ReportAudit.transaction do
      # For some reason, it throws error if creating with user type
      @audit = ReportAudit.create!(audit_params.except(:user_type))
      @audit.update!(user_type: audit_params[:user_type]) if audit_params[:user_type].present?
    end

    render json: V2::AuditSerializer.render(@audit, root: :audit)
  end

  private

  def set_audits
    @audits = ReportAudit.includes(:case_report).filter_records(filtration_params).order(id: :desc)
  end

  def audit_params
    params.require(:audit).permit(:case_report_id, :action, :created_at).merge(enforced_audit_params)
  end

  def enforced_audit_params
    {
      user_name:       requester_name,
      user_type:       requester_role,
      user_id:         requester_id,
      email:           requester_email,
      additional_data: { first_name: requester_first_name, last_name: requester_last_name }
    }
  end

  def index_params
    params.permit(:case_report_id, :version, :action_at, :action_time_from, :action_time_to, :user_id, :incident_number)
  end

  def filtration_params
    default_filtration_params.merge(index_params.to_h).compact
  end
end
