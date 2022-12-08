class Audit < ApplicationRecord
  belongs_to :revision

  enum action: [:show, :create, :update], _prefix: true
end
