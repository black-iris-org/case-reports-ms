class AddCaseReportUserIdToCaseReports < ActiveRecord::Migration[7.0]
  def change
    add_column :case_reports, :case_report_user_id, :integer, null: true
  end
end
