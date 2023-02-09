module FiltrationConcern
  extend ActiveSupport::Concern

  included do
    def default_filtration_params
      { datacenter_id: requester_datacenter }
    end
  end
end