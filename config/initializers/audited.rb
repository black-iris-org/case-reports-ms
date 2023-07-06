require "audited"

Audited::Railtie.initializers.each(&:run)

Audited.config do |config|
  config.audit_class = "::Overrides::MyAudit"
end

Audited.current_user_method = :current_user
