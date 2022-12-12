# frozen_string_literal: true

module Revision::FilterConcern
  extend ActiveSupport::Concern
  include Filterable

  included do
    add_filter(:datacenter_id) { |value| includes(:case_report).where(case_reports_view: { datacenter_id: value }) }
  end
end