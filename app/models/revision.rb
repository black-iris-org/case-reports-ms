class Revision < ApplicationRecord
  include FilterConcern
  include FilesConcern

  belongs_to :old_case_report, optional: true
  has_many :old_audits

  has_one :creation_audit, -> { where(action: :create) }, class_name: 'ReportAudit'
  has_one :update_audit, -> { where(action: :update) }, class_name: 'ReportAudit'

  validates_presence_of :user_id, :responder_name, :name

  before_create :set_defaults
  validate :validate_not_identical

  JSONB_COLUMNS = {
    incident_address: [:name, lat_lng: { coordinates: [] }],
    content: {}
  }.freeze
  PRIMITIVE_COLUMNS = (column_names - %w[id case_report_id user_id] - JSONB_COLUMNS.keys.map(&:to_s)).freeze

  scope :with_case_report, -> { eager_load(:case_report) }

  def validate_not_identical
    if case_report&.revision&.attributes&.except('id') == attributes&.except('id')
      errors.add(:base, :cannot_be_identical)
    end
  end

  def created_at
    creation_audit&.action_at || update_audit&.action_at
  end
end
