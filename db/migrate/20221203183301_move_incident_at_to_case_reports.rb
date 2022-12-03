class MoveIncidentAtToCaseReports < ActiveRecord::Migration[7.0]
  def up
    drop_view :case_reports_view, revert_to_version: 1
    add_column :case_reports, :incident_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
    remove_column :revisions, :incident_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
    replace_view :case_reports_view, version: 2
  end

  def down
    remove_column :case_reports, :incident_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
    add_column :revisions, :incident_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
    replace_view :case_reports_view, version: 1
  end
end
