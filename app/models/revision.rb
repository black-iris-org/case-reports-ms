class Revision < ApplicationRecord
  belongs_to :case_report
  has_many :audits

  enum report_type: [:original, :amended]
end
