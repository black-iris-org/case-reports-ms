class AddDatacenterToCaseReports < ActiveRecord::Migration[7.0]
  def change
    truncate_tables :audits, :revisions, :case_reports
    add_column :case_reports, :datacenter_id, :integer, null: false
    update_view :case_reports_view, version: 3, revert_to_version: 2
  end
end