class AddIncidentIdToCaseReports < ActiveRecord::Migration[7.0]
  def change
    truncate_tables :audits, :revisions, :case_reports
    add_column :case_reports, :incident_id, :integer, null: false
    update_view :case_reports_view, version: 5, revert_to_version: 4

    add_index :case_reports, :incident_id
  end
end
