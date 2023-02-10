class AuditSerializer < ApplicationSerializer
  identifier :id
  fields :revision_id, :user_id, :user_name, :user_type, :action, :action_at, :incident_number, :datacenter_name, :first_name, :last_name
end
