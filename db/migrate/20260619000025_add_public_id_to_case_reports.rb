class AddPublicIdToCaseReports < ActiveRecord::Migration[7.0]
  def change
    add_column :case_reports, :public_id, :string
  end
end
