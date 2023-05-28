class ReportAttachment < ApplicationRecord
  belongs_to :case_report, optional: true, foreign_key: :audit_id
  has_many_attached :files
end
