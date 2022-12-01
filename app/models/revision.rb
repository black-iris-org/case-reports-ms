class Revision < ApplicationRecord
  belongs_to :case_report, optional: true
  has_many :audits

  enum report_type: [:original, :amended]
end
