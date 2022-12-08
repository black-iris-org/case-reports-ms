class Api::V1::RevisionsController < ApplicationController
  before_action :set_case_reports, only: [:index, :show]
  before_action :set_case_report, only: [:index, :show]
  before_action :set_revisions, only: [:index, :show]
  before_action :set_user_filter, only: [:index, :show]
  before_action :set_revision, only: [:show]

  def index
    if @case_report.present?
      render json: CaseReportSerializer.render(@case_report, root: :case_report, view: :with_revisions)
    else
      render json: RevisionSerializer.render(@revisions, root: :reviews, view: :with_case_report)
    end
  end

  def show
    @case_report.set_custom_revision(@revision)
    render json: CaseReportSerializer.render(@case_report)
  end

  private

  def set_case_reports
    @case_reports = CaseReport.with_revision
  end

  def set_case_report
    return if @case_report.present?

    if @revision.present?
      @case_report = @revision.case_report
    elsif params[:case_report_id].present?
      @case_report = @case_reports.find(params[:case_report_id])
    end
  end

  def set_revisions
    @revisions = @case_report.present? ? @case_report.revisions : Revision.all
    @revisions = @revisions.with_case_report
  end

  def set_revision
    @revision = @revisions.find(params[:id])
    @case_report = @revision.case_report if @case_report.blank?
  end

  def set_user_filter
    return unless params[:user_id].present?

    @revisions = @revisions.where(user_id: params[:user_id])
  end
end
