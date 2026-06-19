class AddPublicIdToCaseReports < ActiveRecord::Migration[7.0]
  def change
    add_column :case_reports, :public_id, :string
    add_index :case_reports, :public_id, unique: true
  end
end
