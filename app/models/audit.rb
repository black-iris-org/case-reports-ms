class Audit < ApplicationRecord
  include Audit::FilterConcern

  belongs_to :revision
  has_one :case_report, through: :revision
  delegate :incident_number, :incident_id, to: :case_report
  delegate :id, to: :revision

  enum action: [:show, :create, :update], _prefix: true

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
