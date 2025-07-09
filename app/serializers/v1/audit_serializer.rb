class V1::AuditSerializer < ApplicationSerializer
  identifier :id
  fields :action, :action_at, :user_id, :user_name, :user_type, :auditable_id,
         :incident_number, :datacenter_name, :first_name, :last_name, :email

  field :revision_id do |audit|
    audit.version
  end
end
