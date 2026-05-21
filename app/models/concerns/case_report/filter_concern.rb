# frozen_string_literal: true

module CaseReport::FilterConcern
  extend ActiveSupport::Concern
  include Filterable

  included do
    add_filter(:incident_number) do |value|
      where("incident_number::text ILIKE ?", "%#{value}%")
    end

    add_filter(:case_report_id) do |value|
      where(id: value)
    end

    add_filter(:incident_at) do |value|
      where("DATE(incident_at) = ?", value)
    end

    add_filter(:created_by) do |value|
      where("responder_name ILIKE ?", "%#{value}%")
    end

    add_filter(:incident_address) do |value|
      where(
        "incident_address->>'name' ILIKE :q OR incident_address->>'street' ILIKE :q",
        q: "%#{value}%"
      )
    end
  end

  class_methods do
    def filterable_attributes
      [:id, :datacenter_id, :incident_id, :user_id]
    end
  end
end