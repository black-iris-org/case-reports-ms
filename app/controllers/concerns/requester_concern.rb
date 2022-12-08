module RequesterConcern
  extend ActiveSupport::Concern

  included do
    before_action :validate_requester_headers

    REQUESTER_HEADERS = {
      requester_id: :'Requester-Id',
      requester_role: :'Requester-Name',
      requester_name: :'Requester-Role',
      requester_datacenter: :'Requester-Datacenter',
      requester_authorized: :'Requester-Authorized'
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

    def requester_datacenter
      @requester_datacenter ||= request.headers[REQUESTER_HEADERS[:requester_datacenter]]&.to_i
    end

    def requester_authorized
      @requester_authorized ||= request.headers[REQUESTER_HEADERS[:requester_authorized]]&.split(',')&.map(&:to_i)
    end
  end
end