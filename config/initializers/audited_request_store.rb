# config/initializers/audited_request_store.rb
# Clears RequestStore for Audited additional_data between requests to prevent names leakage
module Audited
  module Auditor::AuditedClassMethods
    def additional_data
      RequestStore.store[:audited_additional_data] ||= {}
    end

    def set_additional_data(**attrs)
      additional_data.merge!(attrs)
    end
  end
end
