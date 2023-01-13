class Api::V1::AuditReportsController < ApplicationController
  include FiltrationConcern
  before_action :validate_email_presence, :set_audits

  def create
    AuditReportJob.perform_later(
      params[:utc_offset],
      params[:user_email],
      requester_id,
      Audit.to_csv(@audits, attributes: %i[user_name action action_at incident_number incident_id revision_id])
      )
    render json: { message: 'Report is being generated' }, status: :ok
  end

  def set_audits
    @audits = Audit.includes(:case_report).filter_records(filtration_params).order(id: :desc)
  end

  def validate_email_presence
    return if params[:user_email].present?

    render json: { error: 'Email is required' }, status: :unprocessable_entity
  end

  def create_params
    params.permit(:case_report_id, :revision_id, :action_at, :action_time_from, :action_time_to, :user_id, :incident_number, :incident_id)
  end
  def filtration_params
    default_filtration_params.merge(incident_ids_filtration_params).merge(create_params.to_h).compact
  end

  def incident_ids_filtration_params
    { incident_id: params[:incident_ids]&.split(',')&.map(&:to_i) }
  end
end
