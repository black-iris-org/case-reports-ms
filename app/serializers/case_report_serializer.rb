class CaseReportSerializer < ApplicationSerializer
  identifier :id
  fields :incident_number, :incident_at, :incident_number,
         :revision_id, :revisions_count, :report_type

  association :revision, blueprint: RevisionSerializer
end
