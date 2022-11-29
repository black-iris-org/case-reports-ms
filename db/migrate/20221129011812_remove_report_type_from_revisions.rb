class RemoveReportTypeFromRevisions < ActiveRecord::Migration[7.0]
  def change
    remove_column :revisions, :report_type, :smallint
  end
end
