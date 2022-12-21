# frozen_string_literal: true

module Audit::FilterConcern
  extend ActiveSupport::Concern
  include Filterable

  included do
    add_filter(:datacenter_id) do |value|
      includes(revision: :case_report).where(revisions: { case_reports_view: { datacenter_id: value } })
    end

    add_filter(:case_report_id) do |value|
      includes(:revision).where(revisions: { case_report_id: value })
    end

    add_filter(:action_at) do |value|
      where(action_at: value.to_time)
    end

    add_filter(:action_time_from, :and) do |value|
      where(action_at: (value.to_time)..nil)
    end

    add_filter(:action_time_to, :and) do |value|
      where(action_at: nil..(value.to_time))
    end
  end

  class_methods do
    def filterable_attributes
      [:revision_id]
    end
  end
end