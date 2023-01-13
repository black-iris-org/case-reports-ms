# frozen_string_literal: true

class AuditReportJob < ApplicationJob
  queue_as :default

  def perform(utc_offset, user_email, user_id, csv_data)

    send_email(
      file_name: "#{user_id}_audit_report_#{Date.current}.csv",
      file_content: csv_data,
      user_email: user_email
    )
  end

  def send_email(params)
    AuditMailer.with(**params).audit_activities.deliver_later
  end
end
