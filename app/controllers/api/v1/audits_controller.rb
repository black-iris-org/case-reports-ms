class Api::V1::AuditsController < ApplicationController
  before_action :set_audits
  before_action :set_revision_filter
  before_action :set_case_report_filter

  def index
    render json: AuditSerializer.render(@audits, root: :audits)
  end

  private

  def set_audits
    @audits = Audit.all
  end

  def set_revision_filter
    return unless params[:revision_id].present?

    @audits = @audits.where(revision_id: params[:revision_id])
  end

  def set_case_report_filter
    return unless params[:case_report_id].present?



    @audits = @audits.includes(revision: :case_report)
                     .where(
                       revisions: {
                         case_reports_view: {
                           id: params[:case_report_id]
                         }
                       }
                     )

    warn @audits.to_sql
  end
end
