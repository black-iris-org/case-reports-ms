class CaseReportSerializer < ApplicationSerializer
  identifier :id
  fields :datacenter_id, :incident_number, :incident_at, :incident_number,
         :revisions_count, :report_type

  association :revision, blueprint: RevisionSerializer

  view :without_revision do
    exclude :revision
  end

  view :with_revisions do
    include_view :without_revision
    association :revisions, blueprint: RevisionSerializer
  end
end