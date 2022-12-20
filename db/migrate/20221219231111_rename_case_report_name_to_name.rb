class RenameCaseReportNameToName < ActiveRecord::Migration[7.0]
  def change
    rename_column :revisions, :case_report_name, :name
    update_view :case_reports_view, version: 6, revert_to_version: 5
  end
end
