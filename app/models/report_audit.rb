class ReportAudit < ::Overrides::MyAudit
  include FilterConcern
  include AdditionalDataConcern
  include CsvConcern

  belongs_to :case_report, foreign_key: :auditable_id

  default_scope { where(auditable_type: CaseReport.name) }

  alias_attribute :user_name, :username
  alias_attribute :action_at, :created_at

  define_additional_attribute :first_name
  define_additional_attribute :last_name

  delegate :datacenter_name, :incident_number, :incident_id, to: :case_report, allow_nil: true
  delegate :id, to: :case_report, prefix: true, allow_nil: true

  def case_report_id=(value)
    self.auditable_id = value
  end

  def case_report_id
    auditable_id
  end
end
