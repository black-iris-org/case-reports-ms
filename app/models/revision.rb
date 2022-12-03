class Revision < ApplicationRecord
  belongs_to :case_report, optional: true
  has_many :audits

  before_create :set_defaults

  def set_defaults
    self.incident_address ||= {}
    self.content ||= {}
  end
end
