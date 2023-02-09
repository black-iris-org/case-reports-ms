module RequesterConcern
  extend ActiveSupport::Concern

  included do
    before_action :validate_requester_headers

    REQUESTER_HEADERS = {
      requester_id: :'Requester-Id',
      requester_role: :'Requester-Role',
      requester_name: :'Requester-Name',
      requester_first_name: :'Requester-First-Name',
      requester_last_name: :'Requester-Last-Name',
      requester_datacenter: :'Requester-Datacenter',
      requester_datacenter_name: :'Requester-Datacenter-Name'
    }

    def validate_requester_headers
      return unless REQUESTER_HEADERS.keys.map { |key| send(key) }.any?(&:blank?)
      head :unauthorized
    end

    def requester_id
      @requester_id ||= request.headers[REQUESTER_HEADERS[:requester_id]]
    end

    def requester_role
      @requester_role ||= request.headers[REQUESTER_HEADERS[:requester_role]]
    end

    def requester_name
      @requester_name ||= request.headers[REQUESTER_HEADERS[:requester_name]]
    end

    def requester_first_name
      @requester_first_name ||= request.headers[REQUESTER_HEADERS[:requester_first_name]]
    end

    def requester_last_name
      @requester_last_name ||= request.headers[REQUESTER_HEADERS[:requester_last_name]]
    end

    def requester_datacenter
      @requester_datacenter ||= request.headers[REQUESTER_HEADERS[:requester_datacenter]]&.to_i
    end

    def requester_datacenter_name
      @requester_datacenter_name ||= request.headers[REQUESTER_HEADERS[:requester_datacenter_name]]
    end
  end
end