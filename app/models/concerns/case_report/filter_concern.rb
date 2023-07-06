# frozen_string_literal: true

module CaseReport::FilterConcern
  extend ActiveSupport::Concern
  include Filterable

  class_methods do
    def filterable_attributes
      [:id, :datacenter_id, :incident_id, :user_id]
    end
  end
end