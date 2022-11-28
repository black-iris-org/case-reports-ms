class CreateRevisions < ActiveRecord::Migration[7.0]
  def change
    create_table :revisions do |t|
      t.belongs_to :case_report, foreign_key: true
      t.column :report_type, :smallint
      t.string :responder_name
      t.string :patient_name
      t.date :patient_dob
      t.jsonb :incident_address
      t.integer :user_id

      t.datetime :incident_at
    end
  end
end
