module FiltrationConcern
  extend ActiveSupport::Concern

  included do
    def default_filtration_params
      { datacenter_id: ([requester_datacenter] + requester_authorized).uniq }
    end
  end
end