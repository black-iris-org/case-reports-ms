class Api::V1::AuditReportsController < ApplicationController
  def create
    incident_ids = params[:incident_ids].split(',')
    authorized_datacenter_ids = ([requester_datacenter] + requester_authorized).uniq
    AuditReportJob.perform_later(
      params[:from_date],
      params[:to_date],
      incident_ids,
      authorized_datacenter_ids,
      params[:utc_offset],
      params[:user_id],
      params[:user_email]
      )
    render json: { message: 'Report is being generated' }, status: :ok
  end
end
