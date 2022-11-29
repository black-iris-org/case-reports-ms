class CaseReport < ApplicationRecord
  self.primary_key = :id
  self.table_name = :case_reports_view

  attribute :revision_id

  enum report_type: [:original, :amended]

  has_many :revisions
  has_one :revision, foreign_key: :id, primary_key: :revision_id
end
