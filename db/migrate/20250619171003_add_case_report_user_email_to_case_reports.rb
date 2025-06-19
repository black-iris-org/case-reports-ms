class AddCaseReportUserEmailToCaseReports < ActiveRecord::Migration[7.0]
  def change
    add_column :case_reports, :case_report_user_email, :string
  end
end
