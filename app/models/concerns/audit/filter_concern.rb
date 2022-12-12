# frozen_string_literal: true

module Audit::FilterConcern
  extend ActiveSupport::Concern
  include Filterable

  included do
    add_filter(:datacenter_id) do |value|
      includes(revision: :case_report).where(revisions: { case_reports_view: { datacenter_id: value } })
    end

    add_filter(:case_report_id) do |value|
      includes(revision: :case_report).where(revisions: { case_reports_view: { id: value } })
    end
  end
end