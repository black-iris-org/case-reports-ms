require 'rails_helper'

RSpec.describe Api::V2::AuditsController, type: :request do
  include JsonResponse

  let(:case_report) { FactoryBot.create(:case_report) }
  let(:case_report_2) { FactoryBot.create(:case_report) }

  let(:headers) do
    {
      'Requester-Id':              '1',
      'Requester-Role':            'Admin',
      'Requester-Name':            Faker::Name.name,
      'Requester-First-Name':      Faker::Name.first_name,
      'Requester-Last-Name':       Faker::Name.last_name,
      'Requester-Datacenter':      '1',
      'Requester-Datacenter-Name': 'test'
    }
  end

  before do
    get "/api/v2/case_reports/#{case_report.id}", headers: headers
  end

  describe 'GET #index' do
    context 'list without filters' do
      it "should return all audits" do
        get "/api/v2/audits", params: { format: :json }, headers: headers

        expect(json_response[:audits][0])
          .to include(
                "case_report_id"  => case_report.id,
                "version"         => 1,
                "action"          => 'show',
                "incident_number" => case_report.incident_number
              )
        expect(json_response[:audits][1])
          .to include(
                "case_report_id"  => case_report.id,
                "version"         => 1,
                "action"          => 'create',
                "incident_number" => case_report.incident_number
              )
      end
    end

    describe 'list with filters' do
      before do
        get "/api/v2/case_reports/#{case_report_2.id}", headers: headers
      end

      context 'case_report_id' do
        it "should return audits that belongs to the same case_report" do
          case_report

          get "/api/v2/case_reports/#{case_report_2.id}/audits", params: { format: :json }, headers: headers

          expect(json_response[:audits].size).to eq(2)
          expect(json_response[:audits].pluck('case_report_id')).to include(case_report_2.id)
          expect(json_response[:audits].pluck('case_report_id')).not_to include(case_report.id)
        end
      end

      context 'version' do
        it "should return audits that belongs to the same case_report" do
          case_report
          get "/api/v2/case_reports/#{case_report_2.id}/audits", params: { version: 1, format: :json }, headers: headers

          expect(json_response[:audits].pluck('version').uniq).to eq([1])
        end
      end

      context 'incident_number' do
        it "should return audits that belongs to the same case_report" do
          case_report

          get "/api/v2/case_reports/#{case_report_2.id}/audits", params: { incident_number: case_report_2.incident_number, format: :json }, headers: headers

          expect(json_response[:audits].pluck('incident_number').uniq).to eq([case_report_2.incident_number])
        end
      end

      context 'user_id' do
        it "should return audits that belongs to the same user" do
          get "/api/v2/case_reports/#{case_report.id}", headers: headers.merge('Requester-Id': 2)
          get "/api/v2/case_reports/#{case_report.id}/audits", params: { user_id: 1, format: :json }, headers: headers

          # using let in spec does not populate user_id field, so we expect 1 here instead of 2
          expect(json_response[:audits].size).to eq(1)

          expect(json_response[:audits].first)
            .to include(
                  "user_id"         => headers[:'Requester-Id'].to_i,
                  "user_name"       => headers[:'Requester-Name'],
                  "datacenter_name" => headers[:'Requester-Datacenter-Name']
                )
        end
      end
    end
  end

  describe 'GET #create' do
    context 'user_id' do
      it "should create new audit with user_id" do

        expect do
          get "/api/v2/case_reports/#{case_report.id}",
              headers: headers,
              params:  { format: :json }.merge(case_report: FactoryBot.build(:case_report).as_json)
        end.to change { ReportAudit.count }.by(1)

        expect(ReportAudit.last.attributes)
          .to include(
                "user_id"         => headers[:'Requester-Id'].to_i,
                "username"        => headers[:'Requester-Name'],
                "additional_data" => {
                  "first_name" => headers[:'Requester-First-Name'],
                  "last_name"  => headers[:'Requester-Last-Name'],
                }
              )
      end
    end
  end
end