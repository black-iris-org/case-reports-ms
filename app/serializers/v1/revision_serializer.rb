class V1::RevisionSerializer < ApplicationSerializer
  field :version, name: :id
  field :id, name: :case_report_id

  fields :user_id, :responder_name, :incident_address, :name, :created_at, :content, :attachments,
         :patient_name, :patient_dob

  field :direct_upload_urls, if: ->(_field_name, _user, options) { options[:with_direct_upload_urls] }
end
