class Revision < ApplicationRecord
  belongs_to :case_report, optional: true
  has_many :audits

  before_create :set_time_stamps

  def set_time_stamps
    self.incident_at = DateTime.now
  end
end
