# frozen_string_literal: true

module CaseReport::FilesConcern
  extend ActiveSupport::Concern
  include Filterable

  included do
    delegate :files, :files_blobs, to: :audit, allow_nil: true

    set_callback :audit, :around, :set_report_attachment

    def files_attributes=(value)
      return if value.blank?

      @report_attachment = ReportAttachment.new
      value.each do |item|
        @report_attachment.files_blobs << (item.is_a?(ActiveStorage::Blob) ? item : ActiveStorage::Blob.create(item))
      end
    end

    def direct_upload_urls
      files&.map { |file| file&.service&.send(:object_for, file&.key)&.presigned_url(:put) } || []
    end

    def attachments
      files&.filter(&:present?)&.map do |file|
        {
          filename:     file.filename.to_s,
          byte_size:    file.byte_size,
          content_type: file.content_type,
          url:          file.service&.send(:object_for, file.key)&.presigned_url(:get),
          public_url:      file.service&.send(:object_for, file.key)&.public_url
        }
      end || []
    end

    def audit
      if audit_version.present?
        audits.order(created_at: :desc).find_by(version: audit_version)
      else
        audits.modifies.last
      end
    end

    def files
      audit.files
    end

    private

    def set_report_attachment
      audit = yield
      return unless audit.auditable_action?

      audit.report_attachment = @report_attachment
      @report_attachment      = nil
    end
  end

  class_methods do
    def filterable_attributes
      [:datacenter_id]
    end
  end
end
