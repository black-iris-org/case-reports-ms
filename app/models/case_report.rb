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
    all_attachments = []
    attachments = self.attachments ? self.attachments.select { |attachment| attachment["content_type"] == "application/pdf" } : []
    content = self.content

    assesment_attachments = content[:assesment] && content[:assesment][:attachments] ? content[:assesment][:attachments].select { |attachment| attachment["content_type"] == "application/pdf" } : []
    file_attributes_attachments = content[:assesment] && content[:assesment][:files_attributes] ? content[:assesment][:files_attributes].select { |attachment| attachment["content_type"] == "application/pdf" } : []
    add_file_attributes_attachments = content[:assesment] && content[:assesment][:add_files_attributes] ? content[:assesment][:add_files_attributes].select { |attachment| attachment["content_type"] == "application/pdf" } : []

    all_attachments.concat(attachments)
    all_attachments.concat(assesment_attachments)
    all_attachments.concat(file_attributes_attachments)
    all_attachments.concat(add_file_attributes_attachments)
    all_attachments.uniq
  end

  def has_attachments?
    pdf_attachments.present? || self.only_pdf_attachments.present?
  end

  # Or should I get these from Beacon by filtering user_id?
  def created_by
    self.content["creator"]["first_name"] + " " + self.content["creator"]["last_name"]
  end
  
  private

  def set_defaults
    self.incident_address ||= {}
    self.content          ||= {}
  end

end
