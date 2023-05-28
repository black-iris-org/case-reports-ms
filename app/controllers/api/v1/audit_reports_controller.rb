class Api::V1::AuditReportsController < ApplicationController
  include FiltrationConcern
  before_action :set_audits

  def create
    AuditReportJob.perform_later(
      params[:utc_offset],
      params[:user_email],
      requester_id,
      @audits.to_csv(attributes: %i[datacenter_name user_name action action_at incident_number incident_id first_name last_name])
      )
    render json: { message: 'Report is being generated' }, status: :ok
  end

  private

  def set_audits
    @audits = ReportAudit.filter_records(filtration_params).order(id: :desc)
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
