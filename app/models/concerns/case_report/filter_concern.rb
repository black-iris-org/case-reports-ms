# frozen_string_literal: true

module CaseReport::FilterConcern
  extend ActiveSupport::Concern
  include Filterable

  class_methods do
    def filterable_attributes
      [:datacenter_id, :incident_id]
    end
  end
end