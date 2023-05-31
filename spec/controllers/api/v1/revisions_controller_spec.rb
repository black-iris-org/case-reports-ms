require 'rails_helper'

RSpec.describe Api::V1::RevisionsController, type: :request do
  include JsonResponse

  let(:case_report_1) { FactoryBot.create(:case_report) }
  let(:case_report_2) { FactoryBot.create(:case_report) }
  let(:revision_1) { case_report_1.revisions.first }
  let(:revision_2) { case_report_1.reload }
  let(:revision_3) { case_report_2.reload }

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
    case_report_1.reload

    put "/api/v1/case_reports/#{case_report_1.id}",
        params:  { case_report: { user_id: 1, responder_name: 'test_2', name: 'test' } },
        headers: headers

    case_report_2.reload
  end

  describe 'GET #index' do
    describe 'list with filters' do
      before do
        case_report_2.reload
      end

      context 'case_report_id' do
        it "should return all revisions of particular case_report" do
          get "/api/v1/case_reports/#{case_report_1.id}/revisions", params: { format: :json }, headers: headers

          expect(json_response[:revisions].size).to eq(2)

          expect(json_response[:revisions].first.with_indifferent_access)
            .to include(id:               case_report_1.id,
                        datacenter_id:    1,
                        incident_id:      case_report_1.incident_id,
                        incident_number:  case_report_1.incident_number,
                        report_type:      'amended',
                        revisions_count:  2,
                        responder_name:   'test',
                        user_id:          1,
                        name:             'test',
                        incident_address: {})

          expect(json_response[:revisions].last.with_indifferent_access)
            .to include(id:               case_report_1.id,
                        datacenter_id:    1,
                        incident_id:      case_report_1.incident_id,
                        incident_number:  case_report_1.incident_number,
                        report_type:      'amended',
                        revisions_count:  2,
                        responder_name:   'test_2',
                        user_id:          1,
                        name:             'test',
                        incident_address: {})
        end
      end
    end
  end
end