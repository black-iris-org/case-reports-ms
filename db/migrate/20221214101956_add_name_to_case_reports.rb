class AddNameToCaseReports < ActiveRecord::Migration[7.0]
  def change
    truncate_tables :audits, :revisions, :case_reports
    add_column :revisions, :case_report_name, :string, null: false
    update_view :case_reports_view, version: 4, revert_to_version: 3
  end
end
