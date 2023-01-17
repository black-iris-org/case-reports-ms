class AddUserIdToView < ActiveRecord::Migration[7.0]
  def change
    update_view :case_reports_view, version: 7, revert_to_version: 6
  end
end
