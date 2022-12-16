module FiltrationConcern
  extend ActiveSupport::Concern

  included do
    def default_filtration_params
      { datacenter_id: ([requester_datacenter] + requester_authorized).uniq }
    end

    def default_filtration_params_with_incident
      default_filtration_params.merge(incident_id: params[:incident_id])
    end
  end
end