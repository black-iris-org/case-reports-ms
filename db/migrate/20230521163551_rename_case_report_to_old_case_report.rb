class RenameCaseReportToOldCaseReport < ActiveRecord::Migration[7.0]
  def change
    rename_table :case_reports, :old_case_reports
  end
end
