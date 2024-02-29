class V1::CaseReportSerializer < ApplicationSerializer
  identifier :id
  fields :datacenter_id, :datacenter_name, :incident_number, :incident_id, :incident_at, :incident_number,
         :revisions_count, :report_type, :user_id, :attachments, :case_report_user_id, :has_attachments

  # Other Views
  view :list_view do
    excludes :attachments
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

  view :pdf_attachments_view do
    field :pdf_attachments do |case_report, _options|
      case_report.pdf_attachments.map do |attachment|
        {
          filename: attachment[:filename],
          byte_size: attachment[:byte_size],
          content_type: attachment[:content_type],
          url: attachment[:url],
          public_url: attachment[:public_url],
          checksum: attachment[:checksum]
        }
      end
    end
  end

  field :has_attachments do |case_report, _options|
    case_report.has_attachments?
  end
end
