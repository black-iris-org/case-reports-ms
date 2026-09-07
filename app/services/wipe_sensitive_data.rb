 class WipeSensitiveData
  Result = Struct.new(:total, :attachments_deleted, :audits_cleared, :errors, keyword_init: true)

  def initialize(current_user)
    @current_user = current_user
  end

  def wipe_one(case_report)
    r = Result.new(total: 1, attachments_deleted: 0, audits_cleared: 0, errors: [])
    wipe!(case_report, r)
    r
  end

  private

  def wipe!(report, result)
    ActiveRecord::Base.transaction do
      ReportAudit.where(auditable_id: report.id).find_each do |audit|
        if audit.report_attachment.present?
          begin
            audit.report_attachment.files.each(&:purge_later)
          rescue => file_err
            Rails.logger.warn("File purge failed for ReportAttachment #{audit.report_attachment.id}: #{file_err.message}")
          end

          audit.report_attachment.destroy
          result.attachments_deleted += 1
        end

        audit.update!(
          audited_changes: {},
          additional_data: {},
          comment: nil
        )
        result.audits_cleared += 1
      end

      report.wipe_sensitive_content!(@current_user)
    end
  rescue => e
    Rails.logger.error("Failed to wipe report #{report.id}: #{e.class} - #{e.message}")
    result.errors << { id: report.id, error: "#{e.class} - #{e.message}" }
  end
end
