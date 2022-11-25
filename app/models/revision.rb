class Revision < ApplicationRecord
  belongs_to :case_report
  has_many :audits
end
