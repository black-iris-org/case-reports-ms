class Api::V1::CaseReportsController < ApplicationController
  include AuditsConcern
  include PaginationConcern
  include FiltrationConcern

  before_action :perform_authorization, only: [:index]
  before_action :set_audit_additional_data, only: [:create, :show, :update, :attachments], unless: :skip_audit?
  before_action :set_case_reports, only: [:show, :update, :index, :attachments]
  before_action :set_case_report, only: [:show, :update, :attachments]

  def index
    render json: V1::CaseReportSerializer.render(
      paginate(@case_reports),
      root: :case_reports, meta: pagination_status,
      view: :list_view
    )
  end

  def create
    @case_report = CaseReport.create!(create_params)
    render json: V1::CaseReportSerializer.render(
      @case_report,
      root: :case_report,
      view: :show_view,
      **serializer_options
    )
  end

  def update
    @case_report.update!(update_params)
    render json: V1::CaseReportSerializer.render(
      @case_report,
      root: :case_report,
      view: :show_view,
      **serializer_options
    )
  end

  def show
    render json: V1::CaseReportSerializer.render(@case_report, root: :case_report, view: :show_view)
  end

  def attachments
    render json: V1::PdfAttachmentsViewSerializer.render(
      @case_report
    )
  end

  def incident_reports_counts
    incident_id = params[:incident_id]
    case_reports_count = CaseReport.where(incident_id: incident_id).count
    revisions_count = CaseReport.where(incident_id: incident_id).sum(&:revisions_count)
    render json: { incident_id: incident_id, case_reports_count: case_reports_count, revisions_count: revisions_count }
  end


  private

  def create_params
    params.require(:case_report)
          .permit(:case_report_user_id, :incident_number, :incident_at, :incident_id, *revision_attributes)
          .merge(user_id:          requester_id,
                 files_attributes: files_attributes,
                 datacenter_id:    requester_datacenter,
                 datacenter_name:  requester_datacenter_name,
          )
  end

  def update_params
    revision_params.merge(
      datacenter_id:   requester_datacenter,
      datacenter_name: requester_datacenter_name
    )
  end

  def revision_attributes
    attributes = (CaseReport::PRIMITIVE_COLUMNS.dup << CaseReport::JSONB_COLUMNS)
    attributes << { files_attributes: files_attributes }
  end

  def files_params
    params.require(:case_report).permit(
      files_attributes:        [:filename, :checksum, :byte_size, :content_type],
      add_files_attributes:    [:filename, :checksum, :byte_size, :content_type],
      remove_files_attributes: [],
    )
  end

  # This will prepare attachments list to be provided to the model
  def files_attributes
    return files_params[:files_attributes] if files_params[:files_attributes].present?

    files_attributes = @case_report&.audit&.report_attachment&.files_blobs.to_a || []

    add_files_attributes    = files_params[:add_files_attributes] || []
    remove_files_attributes = files_params[:remove_files_attributes]

    files_attributes        += add_files_attributes if add_files_attributes.present?

    if remove_files_attributes.present?
      files_attributes.reject! { |file| remove_files_attributes.include? file[:filename] }
    end
    files_attributes
  end

  def revision_params
    params.require(:case_report).permit(*revision_attributes).merge(user_id: requester_id, files_attributes: files_attributes)
  end

  def file_params_present?
    files_params.present?
  end

  def filters
    params.permit(:incident_id).merge(default_filtration_params).merge(auth_params)
  end

  def set_case_report
    @case_report = if skip_audit?
                     @case_reports.find(params[:id])
                   else
                     @case_reports.with_show_auditing { @case_reports.find(params[:id]) }
                   end
  end

  def set_case_reports
    @case_reports = CaseReport.filter_records(filters.to_h).order(id: :desc)
  end

  def serializer_options
    { with_direct_upload_urls: file_params_present? }
  end

  def auth_params
    @auth_params || {}
  end

  def perform_authorization
    if UserRole::MOBILE_USER_ROLES.include?(requester_role)
      if params[:incident_id].blank?
        render json: { error: 'Not authorized' }, status: :unauthorized and return
      else
        @auth_params = { user_id: requester_id }
      end
    end
  end
end
