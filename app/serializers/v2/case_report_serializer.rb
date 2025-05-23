class V2::CaseReportSerializer < ApplicationSerializer
  identifier :id
  fields :datacenter_id, :datacenter_name, :incident_number, :incident_id, :incident_at, :incident_number,
         :revisions_count, :report_type, :user_id, :responder_name, :patient_name, :patient_dob, :incident_address,
         :content, :name, :attachments, :created_at, :updated_at

  field :direct_upload_urls, if: ->(_field_name, _user, options) { options[:with_direct_upload_urls] }

  view :list_view do
    excludes :content, :attachments, :patient_name, :patient_dob
  end

  view :revision_view do
    include_views :list_view
    excludes :revisions_count
    fields :version
  end

  view :full_details do
    excludes :revisions_count
    fields :version
  end
end
