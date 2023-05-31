# frozen_string_literal: true

module ReportAudit::FilterConcern
  extend ActiveSupport::Concern
  include Filterable

  included do
    add_filter(:datacenter_id) do |value|
      includes(:case_report).where(case_reports: { datacenter_id: value })
    end

    add_filter(:case_report_id) do |value|
      includes(:case_report).where(case_reports: { id: value })
    end

    add_filter(:action_at) do |value|
      where(created_at: value.to_time)
    end

    add_filter(:incident_number) do |value|
      includes(:case_report).where(case_reports: { incident_number: value })
    end

    add_filter(:incident_id) do |value|
      includes(:case_report).where(case_reports: { incident_id: value })
    end

    add_filter(:action_time_from, :and) do |value|
      where(created_at: (value.to_time)..nil)
    end

    add_filter(:action_time_to, :and) do |value|
      where(created_at: nil..(value.to_time + 1.day))
    end
  end

  class_methods do
    def filterable_attributes
      [:version, :user_id]
    end
  end
end