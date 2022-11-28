class CreateCaseReports < ActiveRecord::Migration[7.0]
  def change
    create_table :case_reports do |t|
      t.integer :incident_number
    end
  end
end
