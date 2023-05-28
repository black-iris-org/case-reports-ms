class Overrides::MyAudit < ::Audited::Audit
  has_one :report_attachment, dependent: :destroy, foreign_key: :audit_id
  delegate :files, :files_blobs, to: :report_attachment, allow_nil: true
end
