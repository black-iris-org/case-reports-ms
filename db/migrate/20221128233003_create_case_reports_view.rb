class CreateCaseReportsView < ActiveRecord::Migration[7.0]
  def change
    create_view :case_reports_view
  end
end
