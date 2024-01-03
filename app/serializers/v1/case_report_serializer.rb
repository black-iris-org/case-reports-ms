class V1::CaseReportSerializer < ApplicationSerializer
  identifier :id
  fields :datacenter_id, :datacenter_name, :incident_number, :incident_id, :incident_at, :incident_number,
         :revisions_count, :report_type, :user_id, :attachments, :case_report_user_id

  # Other Views
  view :list_view do
    association(:revision, blueprint: ::V1::RevisionSerializer, view: :minimal) { |report| report }
    association :revisions, blueprint: ::V1::RevisionSerializer, view: :minimal
  end

  view :show_view do
    association(:revision, blueprint: ::V1::RevisionSerializer, view: nil) { |report| report }
  end

  view :with_custom_revisions do
    association :revisions, blueprint: ::V1::RevisionSerializer, view: :minimal do |_, options|
      options[:revisions]
    end
  end
end
