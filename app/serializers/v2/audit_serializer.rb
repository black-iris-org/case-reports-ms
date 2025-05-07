class V2::AuditSerializer < ApplicationSerializer
  identifier :id
  fields :case_report_id, :version, :user_id, :user_name, :user_type, :action, :action_at,
         :incident_number, :datacenter_name, :first_name, :last_name, :email
end
