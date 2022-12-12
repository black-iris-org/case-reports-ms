class Audit < ApplicationRecord
  include Audit::FilterConcern

  belongs_to :revision

  enum action: [:show, :create, :update], _prefix: true
end
