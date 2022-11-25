class CaseReport < ApplicationRecord
  attribute :revision_id

  has_many :revisions
end
