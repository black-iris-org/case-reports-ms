class AddDatacenterNameToCaseReports < ActiveRecord::Migration[7.0]
  def change
    add_column :case_reports, :datacenter_name, :string, null: false, default: ""
    update_view :case_reports_view, version: 8, revert_to_version: 7
  end
end
