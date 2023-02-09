require 'rails_helper'

RSpec.describe Api::V1::AuditsController, type: :request do
  include JsonResponse

  let(:case_report)   { FactoryBot.create(:case_report) }
  let(:case_report_2) { FactoryBot.create(:case_report) }
  let(:revision_id)   { case_report.revision.id }
  let(:revision_2_id) { case_report_2.revision.id }
  let(:audit)         { case_report.revision.audits.first }
  let(:audit_2)       { case_report.revision.audits.last }

  let(:headers) do
    {
      'Requester-Id': '1',
      'Requester-Role': 'Admin',
      'Requester-Name': Faker::Name.name,
      'Requester-First-Name': Faker::Name.first_name,
      'Requester-Last-Name': Faker::Name.last_name,
      'Requester-Datacenter': '1',
      'Requester-Datacenter-Name': 'test',
      'Requester-Authorized': '1',
    }
  end

  before do
    case_report.reload
    get "/api/v1/case_reports/#{case_report.id}", headers: headers
  end

  describe 'GET #index' do
    context 'list without filters' do
      it "should return all audits" do
        get "/api/v1/case_reports/#{case_report.id}", headers: headers
        revision_id = case_report.revision.id
        get "/api/v1/revisions/#{revision_id}/audits", params: { format: :json }, headers: headers
        audit_1 = case_report.revision.audits.first
        audit_2 = case_report.revision.audits.last

        expect(json_response[:audits].first.with_indifferent_access).to include(id: audit_1.id, revision_id: revision_id,
                                                                                action: 'show', incident_number: case_report.incident_number)

        expect(json_response[:audits].last.with_indifferent_access).to include(id: audit_2.id, revision_id: revision_id,
                                                                               action: 'show', incident_number: case_report.incident_number)

      end
    end

    describe 'list with filters' do
      before do
        case_report_2.reload
        get "/api/v1/case_reports/#{case_report_2.id}", headers: headers
      end

      context 'case_report_id' do

        it "should return audits that belongs to the same case_report" do

          get "/api/v1/revisions/#{revision_id}/audits", params: { case_report_id: case_report.id, format: :json }, headers: headers

          expect(json_response[:audits].first.with_indifferent_access).to include(revision_id: revision_id)

          expect(json_response[:audits].first.with_indifferent_access).not_to include(revision_id: revision_2_id)

        end
      end

      context 'revision_id' do
        it "should return audits that belongs to the same case_report" do

          get "/api/v1/revisions/#{revision_id}/audits", params: { revision_id: revision_id, format: :json }, headers: headers

          expect(json_response[:audits].first.with_indifferent_access).to include(revision_id: revision_id)

          expect(json_response[:audits].first.with_indifferent_access).not_to include(revision_id: revision_2_id)
        end
      end

      context 'incident_number' do
        it "should return audits that belongs to the same case_report" do

          get "/api/v1/revisions/#{revision_id}/audits", params: { incident_number: case_report.incident_number, format: :json }, headers: headers

          expect(json_response[:audits].first.with_indifferent_access).to include(id: audit.id)
        end
      end

      context 'user_id' do
        it "should return audits that belongs to the same case_report" do
          headers[:user_id] = '2'
          get "/api/v1/case_reports/#{case_report.id}", headers: headers
          get "/api/v1/revisions/#{revision_id}/audits", params: { user_id: '1', format: :json }, headers: headers

          audit_3 = case_report.revision.audits.last

          expect(json_response[:audits].first.with_indifferent_access).to include(id: audit.id)
          expect(json_response[:audits].first.with_indifferent_access).to include(id: audit_3.id)
        end
      end
    end
  end
end