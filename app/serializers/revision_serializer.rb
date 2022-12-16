class RevisionSerializer < ApplicationSerializer
  identifier :id
  fields :case_report_id, :user_id, :responder_name,
         :patient_name, :patient_dob, :incident_address,
         :content, :case_report_name

  view :with_case_report do
    excludes :case_report_id
    association :case_report, blueprint: CaseReportSerializer, view: :without_revision
  end
end
