class CaseReport < ApplicationRecord
  include FilesConcern
  include FilterConcern

  JSONB_COLUMNS     = {
    incident_address: [:name, lat_lng: { coordinates: [] }],
    content:          {}
  }.freeze
  PRIMITIVE_COLUMNS = (column_names - JSONB_COLUMNS.keys.map(&:to_s)).freeze

  audited

  has_many :report_audits, foreign_key: :auditable_id

  before_create :set_defaults

  validates_presence_of :datacenter_id, :incident_number, :incident_id

  enum report_type: [:original, :amended]

  attr_readonly :revisions_count, :report_type, :incident_number, :incident_at, :datacenter_id,
                :datacenter_name, :incident_id

  serialize :incident_address, Serializers::IndifferentHash
  serialize :content, Serializers::IndifferentHash

  scope :by_incident_id, ->(incident_id) { where(incident_id: incident_id) }

  def revisions_count
    revisions.size
  end

  def report_type
    return :original if audit_version == 0
    return :amended if audit_version&.> 0

    revisions.size > 1 ? :amended : :original
  end

  private

  def set_defaults
    self.incident_address ||= {}
    self.content          ||= {}
  end

end
