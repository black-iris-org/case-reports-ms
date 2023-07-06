class CreateNewCaseReports < ActiveRecord::Migration[7.0]
  def change
    create_table :case_reports do |t|
      t.string :name
      t.string :first_name, null: true
      t.string :last_name, null: true
      t.string :responder_name
      t.string :patient_name
      t.string :datacenter_name, null: false, default: ""
      t.column :report_type, :smallint
      t.integer :incident_number
      t.integer :datacenter_id, null: false
      t.integer :incident_id, null: false
      t.integer :user_id
      t.jsonb :incident_address, default: '{}'
      t.jsonb :content, default: '{}'
      t.date :patient_dob

      t.datetime :incident_at, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
  end
end
