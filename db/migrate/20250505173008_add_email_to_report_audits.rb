class AddEmailToReportAudits < ActiveRecord::Migration[7.0]
  def change
    add_column :audits, :email, :string
  end
end
