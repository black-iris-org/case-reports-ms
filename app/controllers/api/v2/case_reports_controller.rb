class Api::V2::CaseReportsController < ApplicationController
  include AuditsConcern
  include PaginationConcern
  include FiltrationConcern

  before_action :perform_authorization, only: [:index, :updates]
  before_action :set_audit_additional_data, only: [:create, :show, :update, :updates]
  before_action :set_case_reports, only: [:show, :update, :index, :updates]
  before_action :set_case_report, only: [:show, :update]

  def index
    render json: V2::CaseReportSerializer.render(
      paginate(@case_reports),
      root: :case_reports, meta: pagination_status,
      view: :list_view
    )
  end

  def create
    @case_report = CaseReport.create!(create_params)
    render json: V2::CaseReportSerializer.render(@case_report, root: :case_report, **serializer_options)
  end

  def update
    @case_report.update!(update_params)
    render json: V2::CaseReportSerializer.render(@case_report, root: :case_report, **serializer_options)
  end

  def show
    render json: V2::CaseReportSerializer.render(@case_report, root: :case_report)
  end

  # Supports Aselo integration API
  def updates
    # Ensure required parameters are present
    unless params[:updated_after].present?
      render json: { error: 'Missing required parameter: updated_after' }, status: :bad_request
      return
    end

    begin
      # Parse the updated_after timestamp
      updated_after = Time.zone.parse(params[:updated_after])
      # Additional validation to ensure we have a valid Time object
      if updated_after.nil?
        render json: { error: 'Invalid timestamp format for updated_after' }, status: :bad_request
        return
      end
    rescue ArgumentError, TypeError
      render json: { error: 'Invalid timestamp format' }, status: :bad_request
      return
    end

    # Get the limit parameter (default to 100)
    limit = (params[:limit] || 100).to_i
    limit = 100 if limit <= 0 || limit > 100

    # Query for updated case reports using the @case_reports from the filter
    case_reports_query = @case_reports.where("created_at >= ?", 10.days.ago)
                                      .where('updated_at > ?', updated_after + 0.000001.seconds)

    # Limit results (ordering is already set to updated_at: :asc in set_case_reports)
    case_reports = case_reports_query.limit(limit + 1) # Get one extra to determine if there are more

    # Check if there are more results
    has_more = case_reports.size > limit
    case_reports = case_reports.first(limit) if has_more

    # Get the next timestamp if there are more results
    next_timestamp = has_more && case_reports.last ? case_reports.last.updated_at.iso8601 : nil

    # Serialize the case reports
    response = {
      status: 'success',
      case_reports: V2::CaseReportSerializer.render_as_hash(
        case_reports,
        view: :full_details
      )
    }

    # Add next_timestamp if there are more results
    response[:next_timestamp] = next_timestamp if next_timestamp

    render json: response, status: :ok
  end

  private

  def create_params
    params.require(:case_report)
          .permit(:incident_number, :incident_at, :incident_id, *revision_attributes)
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
    @case_reports = CaseReport.filter_records(filters.to_h)
    if action_name == 'updates'
      # For the updates action, we want oldest first for Aselo poller
      # The specific query in the updates method will further refine this
      @case_reports = @case_reports.order(updated_at: :asc)
    else
      @case_reports = @case_reports.order(id: :desc)
    end
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
