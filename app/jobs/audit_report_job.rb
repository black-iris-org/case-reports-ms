# frozen_string_literal: true

class AuditReportJob < ApplicationJob
  queue_as :default

  # @param [String] from_date
  # @param [String] to_date
  # @param [Array<Integer>] incident_ids
  # @param [Array<Integer>] authorized_datacenter_ids
  # @param [Integer] utc_offset
  def perform(from_date, to_date, incident_ids, authorized_datacenter_ids, utc_offset, user_id, user_email)
    data = query(from_date, to_date, incident_ids, authorized_datacenter_ids, utc_offset)
    csv = Audit.to_csv(data, attributes: %i[user_name action action_at])
    send_email(
      file_name: "#{user_id}_audit_report_#{Date.current}.csv",
      file_content: csv,
      user_email: user_email
    )
  end

  def send_email(params)
    AuditMailer.with(**params).audit_activities.deliver_later
  end

  def query(from_date, to_date, incident_ids, authorized_datacenter_ids, utc_offset)
    if from_date.present? && to_date.present?
      Audit.by_date_range(from_date, to_date, incident_ids, authorized_datacenter_ids, utc_offset)
    else
      Audit.last_30_days(incident_ids, authorized_datacenter_ids, utc_offset)
    end
  end
end
