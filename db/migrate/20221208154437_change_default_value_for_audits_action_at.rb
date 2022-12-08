class ChangeDefaultValueForAuditsActionAt < ActiveRecord::Migration[7.0]
  def change
    change_column_default :audits, :action_at, from: nil, to: -> { 'CURRENT_TIMESTAMP' }
  end
end
