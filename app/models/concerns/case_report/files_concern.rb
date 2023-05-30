# frozen_string_literal: true

module CaseReport::FilesConcern
  extend ActiveSupport::Concern
  include Filterable

  included do
    # has_many_attached :files
    delegate :files, :files_blobs, to: :audit, allow_nil: true

    after_save :set_report_attachment

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
          url:          file.service&.send(:object_for, file.key)&.presigned_url(:get)
        }
      end || []
    end

    def audit
      if audit_version.present?
        audits.find_by(version: audit_version)
      else
        audits.creates.or(audits.updates).last
      end
    end

    def files
      # TODO: to find the right revision number
      audit.files
    end

    private

    def set_report_attachment
      return true if @report_attachment.blank?
      audit = audits.creates.or(audits.updates).last

      return if audit.blank?
      audit.report_attachment = @report_attachment

      @report_attachment = nil
    end
  end

  class_methods do
    def filterable_attributes
      [:datacenter_id]
    end
  end
end
