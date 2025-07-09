require 'csv'

namespace :case_report do
  desc "Populate case_report_user_email from user ID/email CSV"
  task populate_case_report_user_email: :environment do
    file_path = File.expand_path("/home/ubuntu/beacon/public/case_report_user_ids.csv")
    puts "Reading CSV from: #{file_path}"

    user_email_map = {}

    CSV.foreach(file_path, headers: true) do |row|
      user_id = row['ID']&.to_i
      email = row['Email']
      user_email_map[user_id] = email if user_id && email
    end

    puts "Loaded #{user_email_map.size} user ID/email pairs from CSV."

    CaseReport.find_each do |case_report|
      user_id = case_report.case_report_user_id
      email = user_email_map[user_id]

      if email.present?
        if case_report.case_report_user_email.blank?
          case_report.update!(case_report_user_email: email)
          puts "✅ Updated CaseReport ID #{case_report.id} with email #{email}"
        end
      else
        puts "⚠️ No email found for user ID #{user_id}, CaseReport ID #{case_report.id}"
      end
    end
  end
end
