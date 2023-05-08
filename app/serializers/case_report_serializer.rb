class CaseReportSerializer < ApplicationSerializer
  identifier :id
  fields :datacenter_id, :datacenter_name, :incident_number, :incident_id, :incident_at, :incident_number,
         :revisions_count, :report_type

  association :revision, blueprint: RevisionSerializer

  view :without_revision do
    exclude :revision
  end

  view :without_health_data do
    association :revisions, view: :without_health_data, blueprint: RevisionSerializer do |case_report, options|
      options[:custom_revision_list] || case_report.revisions
    end
    association :revision, view: :without_health_data, blueprint: RevisionSerializer do |case_report, options|
      options[:custom_revision_list] || case_report.revision
    end
  end

  view :with_revisions do
    include_view :without_revision
    association :revisions, view: :without_health_data, blueprint: RevisionSerializer do |case_report, options|
      options[:custom_revision_list] || case_report.revisions
    end
  end

  view :full_details do
    include_view :without_revision
    association :revisions, view: nil, blueprint: RevisionSerializer do |case_report, options|
      options[:custom_revision_list] || case_report.revisions
    end
  end
end
