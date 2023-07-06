class Overrides::MyAudit < ::Audited::Audit
  has_one :report_attachment, dependent: :destroy, foreign_key: :audit_id

  def files_blobs
    report_attachment&.files_blobs || []
  end

  def files
    report_attachment&.files || []
  end
end
