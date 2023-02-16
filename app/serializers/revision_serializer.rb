class RevisionSerializer < ApplicationSerializer
  identifier :id
  fields :case_report_id, :user_id, :responder_name,
         :patient_name, :patient_dob, :incident_address,
         :content, :name, :attachments, :created_at

  field :direct_upload_urls, if: ->(_field_name, _user, options) { options[:with_direct_upload_urls] }

  view :with_case_report do
    excludes :case_report_id
    association :case_report, blueprint: CaseReportSerializer, view: :without_revision
  end

  view :without_health_data do
    excludes :content, :attachments
  end
end
