class V1::CaseReportSerializer < ApplicationSerializer
  identifier :id
  fields :incident_number, :incident_id, :incident_at,
         :report_type, :attachments, :case_report_user_id, :case_report_user_email

  # Other Views
  view :list_view do
    excludes :attachments
    association(:revision, blueprint: ::V1::RevisionSerializer) { |report| report }
    field :has_attachments do |case_report, _options|
      case_report.has_attachments?
    end
    field :pdf_attachments_count do |case_report, _options|
      case_report.pdf_attachments.count
    end
  end

  view :show_view do
    association(:revision, blueprint: ::V1::RevisionSerializer) { |report| report }
  end

  view :with_custom_revisions do
    association :revisions, blueprint: ::V1::RevisionSerializer do |_, options|
      options[:revisions]
    end
  end
end
