module RequesterConcern
  extend ActiveSupport::Concern

  included do
    before_action :validate_requester_headers

    REQUESTER_HEADERS = {
      requester_id: :'Requester-Id',
      requester_role: :'Requester-Role',
      requester_name: :'Requester-Name',
      requester_email: :'Requester-Email',
      requester_first_name: :'Requester-First-Name',
      requester_last_name: :'Requester-Last-Name',
      requester_datacenter: :'Requester-Datacenter',
      requester_datacenter_name: :'Requester-Datacenter-Name'
    }

    def validate_requester_headers
      missing_headers = REQUESTER_HEADERS.keys.select { |key| send(key).nil? }

      if missing_headers.any?
        logger.error "Missing Requester Headers: #{missing_headers.join(', ')}"
        head :unauthorized
      end
    end

    def requester_id
      @requester_id ||= request.headers[REQUESTER_HEADERS[:requester_id]]
    end

    def requester_role
      @requester_role ||= request.headers[REQUESTER_HEADERS[:requester_role]]
    end

    def requester_name
      raw_name = request.headers[REQUESTER_HEADERS[:requester_name]]
      @requester_name ||= raw_name.force_encoding('UTF-8')
    end

    def requester_email
      @requester_email ||= request.headers[REQUESTER_HEADERS[:requester_email]]
    end

    def requester_first_name
      raw_name = request.headers[REQUESTER_HEADERS[:requester_first_name]]
      @requester_first_name ||= raw_name.force_encoding('UTF-8')
    end

    def requester_last_name
      raw_name = request.headers[REQUESTER_HEADERS[:requester_last_name]]
      @requester_last_name ||= raw_name.force_encoding('UTF-8')
    end

    def requester_datacenter
      @requester_datacenter ||= request.headers[REQUESTER_HEADERS[:requester_datacenter]]&.to_i
    end

    def requester_datacenter_name
      raw_name = request.headers[REQUESTER_HEADERS[:requester_datacenter_name]]
      @requester_datacenter_name ||= raw_name.force_encoding('UTF-8')
    end
  end
end
