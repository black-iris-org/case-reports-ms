class Revision < ApplicationRecord
  belongs_to :case_report, optional: true
  has_many :audits

  validates_presence_of :user_id, :responder_name

  before_create :set_defaults
  validate :validate_not_identical

  def set_defaults
    self.incident_address ||= {}
    self.content ||= {}
  end

  def validate_not_identical
    if case_report&.revision&.attributes&.except('id') == attributes&.except('id')
      errors.add(:base, :cannot_be_identical)
    end
  end
end
