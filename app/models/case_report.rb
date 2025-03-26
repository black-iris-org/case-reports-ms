class CaseReport < ApplicationRecord
  audited

  include FilesConcern
  include FilterConcern

  JSONB_COLUMNS     = {
    incident_address: [:name, lat_lng: { coordinates: [] }],
    content:          {}
  }.freeze
  PRIMITIVE_COLUMNS = (column_names - ['id'] - JSONB_COLUMNS.keys.map(&:to_s)).freeze

  has_many :report_audits, foreign_key: :auditable_id

  before_create :set_defaults

  validates_presence_of :datacenter_id, :incident_number, :incident_id

  enum report_type: [:original, :amended]

  attr_readonly :revisions_count, :report_type, :incident_number, :incident_at, :datacenter_id,
                :datacenter_name, :incident_id, :case_report_user_id

  serialize :incident_address, Serializers::IndifferentHash
  serialize :content, Serializers::IndifferentHash

  scope :by_incident_id, ->(incident_id) { where(incident_id: incident_id) }

  alias_attribute :version, :audit_version

  def revisions_count
    revisions.size
  end

  def report_type
    return :amended if audit_version&.> 1

    revisions.size > 1 ? :amended : :original
  end

  # Print current created_at, if the object was a revision, it will print the corresponding audit time
  def created_at
    super || audit&.created_at
  end


  def pdf_attachments
    self.only_pdf_attachments
  end

  def has_attachments?
    self.only_pdf_attachments.present?
  end

  def created_by
    if self.content["creator"].present?
      self.content["creator"]["first_name"] + " " + self.content["creator"]["last_name"]
    else
      self.responder_name
  end
  
  private

  def set_defaults
    self.incident_address ||= {}
    self.content          ||= {}
  end

end
