class Audit < ApplicationRecord
  belongs_to :revision

  enum action: [:view, :create, :amend], _prefix: true
end
