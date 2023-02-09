require 'rails_helper'

RSpec.describe Api::V1::RevisionsController, type: :request do
  include JsonResponse

  let(:case_report_1) { FactoryBot.create(:case_report) }
  let(:case_report_2) { FactoryBot.create(:case_report) }
  let(:revision_1)    { case_report_1.revisions.first }
  let(:revision_2)    { case_report_1.reload.revision }
  let(:revision_3)    { case_report_2.reload.revision }

  let(:headers) do
    {
      'Requester-Id': '1',
      'Requester-Role': 'Admin',
      'Requester-Name': Faker::Name.name,
      'Requester-First-Name': Faker::Name.first_name,
      'Requester-Last-Name': Faker::Name.last_name,
      'Requester-Datacenter': '1',
    }
  end

  before do
    case_report_1.reload

    put "/api/v1/case_reports/#{case_report_1.id}",
        params: { case_report: { user_id: 1, responder_name: 'test_2', name: 'test' } },
        headers: headers

    case_report_2.reload
  end

  describe 'GET #index' do
    context 'list without filters' do
      it "should return all revisions related to same datacenter" do
        get "/api/v1/revisions", params: { format: :json }, headers: headers

        expect(json_response[:revisions].count).to eq(3)
        expect(json_response[:revisions].first.with_indifferent_access).to include(id: revision_1.id,
                                                                                   responder_name: 'test', user_id: 1,
                                                                                   name: 'test', attachments: [],
                                                                                   content: {}, patient_dob: nil,
                                                                                   patient_name: nil)

        expect(json_response[:revisions].second.with_indifferent_access).to include(id: revision_2.id, responder_name: 'test_2',
                                                                                    user_id: 1, name: 'test',
                                                                                    attachments: [], content: {},
                                                                                    patient_dob: nil, patient_name: nil)

        expect(json_response[:revisions].last.with_indifferent_access).to include(id: revision_3.id, responder_name: 'test',
                                                                                  user_id: 1, name: 'test',
                                                                                  attachments: [], content: {},
                                                                                  patient_dob: nil, patient_name: nil)
      end
    end

    describe 'list with filters' do
      before do
        case_report_2.reload
      end

      context 'case_report_id' do
        it "should return all revisions inside case_report which is related for case report id and the same datacenter" do
          get "/api/v1/case_reports/#{case_report_1.id}/revisions", params: { format: :json }, headers: headers

          expect(json_response[:case_report][:revisions].count).to eq(2)

          expect(json_response[:case_report].with_indifferent_access).to include(id: case_report_1.id,
                                                                                 datacenter_id: 1,
                                                                                 incident_id: case_report_1.incident_id,
                                                                                 incident_number: case_report_1.incident_number,
                                                                                 report_type: 'amended',
                                                                                 revisions_count: 2)

          expect(json_response[:case_report][:revisions].first.with_indifferent_access).to include(id: revision_1.id,
                                                                                                   responder_name: 'test',
                                                                                                   user_id: 1,
                                                                                                   name: 'test',
                                                                                                   case_report_id: case_report_1.id,
                                                                                                   attachments: [],
                                                                                                   incident_address: {},
                                                                                                   content: {},
                                                                                                   patient_dob: nil,
                                                                                                   patient_name: nil)

          expect(json_response[:case_report][:revisions].last.with_indifferent_access).to include(id: revision_2.id,
                                                                                                  responder_name: 'test_2',
                                                                                                  user_id: 1,
                                                                                                  name: 'test',
                                                                                                  case_report_id: case_report_1.id,
                                                                                                  attachments: [],
                                                                                                  incident_address: {},
                                                                                                  content: {},
                                                                                                  patient_dob: nil,
                                                                                                  patient_name: nil)
        end
      end

      context 'user_id' do
        it "should return all revisions which is related for user id and the same datacenter" do
          get "/api/v1/users/1/revisions", params: { format: :json }, headers: headers

          expect(json_response[:revisions].count).to eq(3)

          expect(json_response[:revisions].first[:case_report].with_indifferent_access).to include(id: case_report_1.id,
                                                                                                   datacenter_id: 1,
                                                                                                   incident_id: case_report_1.incident_id,
                                                                                                   incident_number: case_report_1.incident_number,
                                                                                                   report_type: 'amended',
                                                                                                   revisions_count: 2)

          expect(json_response[:revisions].first.with_indifferent_access).to include(id: revision_1.id,
                                                                                     responder_name: 'test',
                                                                                     user_id: 1,
                                                                                     name: 'test',
                                                                                     attachments: [],
                                                                                     incident_address: {},
                                                                                     content: {},
                                                                                     patient_dob: nil,
                                                                                     patient_name: nil)

          expect(json_response[:revisions].second.with_indifferent_access).to include(id: revision_2.id,
                                                                                      responder_name: 'test_2',
                                                                                      user_id: 1,
                                                                                      name: 'test',
                                                                                      attachments: [],
                                                                                      incident_address: {},
                                                                                      content: {},
                                                                                      patient_dob: nil,
                                                                                      patient_name: nil)

          expect(json_response[:revisions].last.with_indifferent_access).to include(id: revision_3.id,
                                                                                    responder_name: 'test',
                                                                                    user_id: 1,
                                                                                    name: 'test',
                                                                                    attachments: [],
                                                                                    incident_address: {},
                                                                                    content: {},
                                                                                    patient_dob: nil,
                                                                                    patient_name: nil)
        end
      end
    end
  end

  describe 'GET #show' do
    context 'show without filters' do
      it "should return revision inside case_report" do
        get "/api/v1/revisions/#{revision_1.id}", params: { format: :json }, headers: headers

        expect(json_response[:case_report].with_indifferent_access).to include(id: case_report_1.id,
                                                                               datacenter_id: 1,
                                                                               incident_id: case_report_1.incident_id,
                                                                               incident_number: case_report_1.incident_number,
                                                                               report_type: 'amended',
                                                                               revisions_count: 2)

        expect(json_response[:case_report][:revision].with_indifferent_access).to include(id: revision_1.id,
                                                                                          responder_name: 'test',
                                                                                          user_id: 1,
                                                                                          name: 'test',
                                                                                          attachments: [],
                                                                                          content: {},
                                                                                          patient_dob: nil,
                                                                                          patient_name: nil)
      end
    end

    context 'show with filters' do
      before do
        case_report_2.reload
      end

      context 'case_report_id' do
        it "should return revision which is related to case_report inside case_report" do
          get "/api/v1/case_reports/#{case_report_1.id}/revisions/#{revision_1.id}", params: { format: :json }, headers: headers

          expect(json_response[:case_report].with_indifferent_access).to include(id: case_report_1.id,
                                                                                 datacenter_id: 1,
                                                                                 incident_id: case_report_1.incident_id,
                                                                                 incident_number: case_report_1.incident_number,
                                                                                 report_type: 'amended',
                                                                                 revisions_count: 2)

          expect(json_response[:case_report][:revision].with_indifferent_access).to include(id: revision_1.id,
                                                                                            responder_name: 'test',
                                                                                            user_id: 1,
                                                                                            name: 'test',
                                                                                            case_report_id: case_report_1.id,
                                                                                            attachments: [],
                                                                                            incident_address: {},
                                                                                            content: {},
                                                                                            patient_dob: nil,
                                                                                            patient_name: nil)
        end
      end

      context 'user_id' do
        it "should return revision which is related for user id" do
          get "/api/v1/users/1/revisions/#{revision_1.id}", params: { format: :json }, headers: headers

          expect(json_response[:case_report].with_indifferent_access).to include(id: case_report_1.id,
                                                                                 datacenter_id: 1,
                                                                                 incident_id: case_report_1.incident_id,
                                                                                 incident_number: case_report_1.incident_number,
                                                                                 report_type: 'amended',
                                                                                 revisions_count: 2)

          expect(json_response[:case_report][:revision].with_indifferent_access).to include(id: revision_1.id,
                                                                                            responder_name: 'test',
                                                                                            user_id: 1,
                                                                                            name: 'test',
                                                                                            case_report_id: case_report_1.id,
                                                                                            attachments: [],
                                                                                            incident_address: {},
                                                                                            content: {},
                                                                                            patient_dob: nil,
                                                                                            patient_name: nil)
        end
      end
    end

    context 'create audit once show revision' do
      it do
        get "/api/v1/revisions/#{revision_1.id}", params: { format: :json }, headers: headers
        expect(Audit.count).to eq(2)
      end
    end
  end
end