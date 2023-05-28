class CaseReport < ApplicationRecord
  include FilesConcern
  include FilterConcern

  audited

  has_many :report_audits, foreign_key: :auditable_id

  JSONB_COLUMNS = {
    incident_address: [:name, lat_lng: { coordinates: [] }],
    content: {}
  }.freeze
  PRIMITIVE_COLUMNS = (column_names - JSONB_COLUMNS.keys.map(&:to_s)).freeze

  # attr_readonly :revision_id, :revisions_count, :report_type, :incident_number, :incident_at, :datacenter_id,
  #               :datacenter_name, :incident_id

  def revisions_count
    revisions.size
  end

  def report_type
    return :original if audit_version == 1
    return :amended if audit_version&.> 1

    revisions.size > 1 ? :amended : :original
  end
end
