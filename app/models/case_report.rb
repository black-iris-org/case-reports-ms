class CaseReport < ApplicationRecord
  include CaseReport::RevisionSavingConcern
  include CaseReport::FilterConcern

  self.primary_key = :id
  set_to_view

  attribute :revision_id
  attribute :revision
  attr_readonly :revision_id, :revisions_count, :report_type,
                :incident_number, :incident_at, :datacenter_id

  enum report_type: [:original, :amended]

  has_many :revisions
  has_one :revision, foreign_key: :id, primary_key: :revision_id

  accepts_nested_attributes_for :revisions

  validates_presence_of :datacenter_id, :incident_number

  before_create :set_defaults

  scope :without_review_column, -> { select(column_names - ['review_id']) }
  scope :with_revision, -> { eager_load(:revision) }

  def set_defaults
    self.incident_at ||= Time.now
  end

  def set_custom_revision(value)
    instance_eval do
      def revision
        @revision
      end
    end
    @revision = value
  end
end
