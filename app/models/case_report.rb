class CaseReport < ApplicationRecord
  include CaseReport::RevisionSavingConcern

  self.primary_key = :id
  set_to_view

  attribute :revision_id
  attribute :revision
  attr_readonly :revision_id, :revisions_count, :report_type, :incident_number

  enum report_type: [:original, :amended]

  has_many :revisions
  has_one :revision, foreign_key: :id, primary_key: :revision_id

  accepts_nested_attributes_for :revision
end
