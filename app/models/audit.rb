class Audit < ApplicationRecord
  include Audit::FilterConcern

  belongs_to :revision
  enum action: [:show, :create, :update], _prefix: true

  scope :last_30_days, lambda { |incident_ids, authorized_datacenter_ids, utc_offset = nil|
    by_date_range(30.days.ago.beginning_of_day, nil, incident_ids, authorized_datacenter_ids, utc_offset)
  }
  scope :by_date_range, lambda { |from_date, to_date, incident_ids, authorized_datacenter_ids, utc_offset = nil|
    from_date = from_date.nil? ? nil : DateTime.parse("#{from_date}T00:00:00 #{utc_offset}")
    to_date = to_date.nil? ? nil : DateTime.parse("#{to_date}T00:00:00 #{utc_offset}")

    Audit.joins(revision: [:case_report])
         .select('audits.*')
         .where(action_at: from_date..to_date).where(case_reports_view: { incident_id: incident_ids }).where(case_reports_view: { datacenter_id: authorized_datacenter_ids })
  }

  def self.to_csv(data, attributes: column_names)
    attributes = attributes.map(&:to_sym)
    CSV.generate(headers: true) do |csv|
      csv << attributes
      data.each do |item|
        csv << attributes.map { |attr| item.send(attr) }
      end
    end
  end
end
