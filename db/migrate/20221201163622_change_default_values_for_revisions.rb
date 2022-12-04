class ChangeDefaultValuesForRevisions < ActiveRecord::Migration[7.0]
  def change
    change_column_default :revisions, :incident_at, from: nil, to: -> { 'CURRENT_TIMESTAMP' }
    change_column_default :revisions, :content, from: nil, to: '{}'
    change_column_default :revisions, :incident_address, from: nil, to: '{}'
  end
end
