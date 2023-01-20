class Revision < ApplicationRecord
  include Revision::FilterConcern
  include Revision::FilesConcern

  belongs_to :case_report, optional: true
  has_many :audits

  validates_presence_of :user_id, :responder_name

  before_create :set_defaults
  validate :validate_not_identical

  JSONB_COLUMNS = {
    incident_address: [:name, lat_lng: { coordinates: [] }],
    content: {}
  }.freeze
  PRIMITIVE_COLUMNS = (column_names - %w[id case_report_id user_id] - JSONB_COLUMNS.keys.map(&:to_s)).freeze

  validates_presence_of :name

  scope :with_case_report, -> { eager_load(:case_report) }

  serialize :incident_address, Serializers::IndifferentHash
  serialize :content, Serializers::IndifferentHash

  def set_defaults
    self.incident_address ||= {}
    self.content ||= {}
  end

  def validate_not_identical
    if case_report&.revision&.attributes&.except('id') == attributes&.except('id')
      errors.add(:base, :cannot_be_identical)
    end
  end
end
