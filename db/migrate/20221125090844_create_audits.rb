class CreateAudits < ActiveRecord::Migration[7.0]
  def change
    create_table :audits do |t|
      t.belongs_to :revision, foreign_key: true
      t.integer :user_id
      t.string :user_name
      t.string :user_type
      t.column :action, :smallint

      t.datetime :action_at
    end
  end
end
