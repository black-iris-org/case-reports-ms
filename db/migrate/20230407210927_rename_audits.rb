class RenameAudits < ActiveRecord::Migration[7.0]
  def change
    rename_table :audits, :old_audits
  end
end
