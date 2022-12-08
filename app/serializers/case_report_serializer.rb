class CaseReportSerializer < ApplicationSerializer
  identifier :id
  fields :datacenter_id, :incident_number, :incident_at, :incident_number,
         :revision_id, :revisions_count, :report_type

  association :revision, blueprint: RevisionSerializer

  view :without_revision do
    exclude :revision
  end
end
