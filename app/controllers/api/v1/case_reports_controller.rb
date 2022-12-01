class Api::V1::CaseReportsController < ApplicationController
  before_action :set_case_report, only: :show

  def create
    render json: CaseReport.create(case_report_create_params)
  end

  def show
    render json: @case_report
  end

  private

  def case_report_create_params
    params.require(:case_report).permit(
      :incident_number,
      revision_attributes: %w[user_id responder_name patient_name patient_dob incident_address content incident_at]
    )
  end

  def set_case_report
    @case_report = CaseReport.find(params[:id])
  end
end
