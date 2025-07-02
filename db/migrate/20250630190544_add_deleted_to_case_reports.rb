class AddDeletedToCaseReports < ActiveRecord::Migration[7.0]
  def change
    add_column :case_reports, :deleted, :boolean
  end
end
