class AddFirstLastNamesToAudits < ActiveRecord::Migration[7.0]
  def change
    add_column :audits, :first_name, :string, null: true
    add_column :audits, :last_name, :string, null: true
  end
end
