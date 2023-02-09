require 'rails_helper'

RSpec.describe Api::V1::CaseReportsController, type: :request do
  include JsonResponse

  let(:case_report_1)    { FactoryBot.create(:case_report) }
  let(:case_report_2)    { FactoryBot.create(:case_report) }
  let(:case_report_3)    { FactoryBot.create(:case_report, incident_id: '2') }
  let(:revision_1)       { case_report_1.reload.revision }
  let(:revision_2)       { case_report_2.reload.revision }
  let(:valid_attributes) { { incident_number: 1, incident_id: 1, datacenter_id: 1, datacenter_name: 'test', incident_at: Time.now,
                             report_type: :amended, user_id: 1, responder_name: 'test', name: 'test' } }

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

  describe 'POST #create' do
    context 'valid attributes' do
      before do
        post "/api/v1/case_reports", params: { case_report: valid_attributes }, headers: headers
      end

      it 'should create case_report' do
        expect(CaseReport.count).to eq(1)
        expect(json_response[:case_report].with_indifferent_access).to include(datacenter_id: 1,
                                                                               datacenter_name: 'test',
                                                                               incident_id: valid_attributes[:incident_id],
                                                                               incident_number: valid_attributes[:incident_number],
                                                                               report_type: 'original',
                                                                               revisions_count: 1)
      end

      it 'should create revision' do
        expect(Revision.count).to eq(1)
        expect(json_response[:case_report][:revision].with_indifferent_access).to include(responder_name: 'test',
                                                                                          user_id: 1,
                                                                                          name: 'test',
                                                                                          attachments: [],
                                                                                          incident_address: {},
                                                                                          content: {},
                                                                                          patient_dob: nil,
                                                                                          patient_name: nil)
      end

      it 'should create audit' do
        expect(Audit.count).to eq(1)
        expect(Audit.last.attributes.with_indifferent_access).to include(
                                           revision_id: Revision.last.id,
                                           user_id: headers[:'Requester-Id'].to_i,
                                           user_name: headers[:'Requester-Name'],
                                           first_name: headers[:'Requester-First-Name'],
                                           last_name: headers[:'Requester-Last-Name'],
                                           user_type: headers[:'Requester-Role'],
                                           action: 'create'
                                         )
      end

      it 'report_type is original once created' do
        expect(json_response[:case_report]['report_type']).to eq('original')
      end
    end
  end

  describe 'PUT #update' do
    before do
      case_report_1.reload
    end
    context 'valid update columns' do
      before do
        put "/api/v1/case_reports/#{case_report_1.id}",
            params: { case_report: { user_id: 1, responder_name: 'test_2', name: 'test' } },
            headers: headers
        case_report_1.reload
      end

      it 'should update case_report' do
        expect(json_response[:case_report].with_indifferent_access).to include(datacenter_id: 1,
                                                                               datacenter_name: 'test',
                                                                               incident_id: case_report_1.incident_id,
                                                                               incident_number: case_report_1.incident_number,
                                                                               report_type: 'amended',
                                                                               revisions_count: 2)
      end

      it 'should create revision' do
        expect(Revision.count).to eq(2)
        expect(json_response[:case_report][:revision].with_indifferent_access).to include(responder_name: 'test_2',
                                                                                          user_id: 1,
                                                                                          name: 'test',
                                                                                          attachments: [],
                                                                                          incident_address: {},
                                                                                          content: {},
                                                                                          patient_dob: nil,
                                                                                          patient_name: nil)
      end

      it 'should create audit' do
        expect(Audit.count).to eq(1)
      end

      it 'report_type is amended once updated' do
        expect(json_response[:case_report]['report_type']).to eq('amended')
      end
    end

    context 'can not update user_id column' do
      before do
        put "/api/v1/case_reports/#{case_report_1.id}",
            params: { case_report: { user_id: 2, responder_name: 'test_2', name: 'test' } },
            headers: headers
        case_report_1.reload
      end

      it 'should return user_id and  Requester-Id are the same' do
        expect(json_response[:case_report][:revision][:user_id]).to eq(1)
      end
    end
  end

  describe 'GET #show' do
    before do
      case_report_1.reload
    end

    context 'return case_report' do
      before do
        get "/api/v1/case_reports/#{case_report_1.id}", headers: headers
        case_report_1.reload.revision.reload
      end

      it do
        expect(json_response[:case_report].with_indifferent_access).to include(datacenter_id: 1,
                                                                               datacenter_name: 'test',
                                                                               incident_id: case_report_1.incident_id,
                                                                               incident_number: case_report_1.incident_number,
                                                                               report_type: 'original',
                                                                               revisions_count: 1)
      end

      it 'should create revision' do
        expect(json_response[:case_report][:revision].with_indifferent_access).to include(responder_name: 'test',
                                                                                          user_id: 1,
                                                                                          name: 'test',
                                                                                          attachments: [],
                                                                                          incident_address: {},
                                                                                          content: {},
                                                                                          patient_dob: nil,
                                                                                          patient_name: nil)
      end

      it 'should create audit' do
        expect(Audit.count).to eq(1)
      end

      it 'report_type still original once shown' do
        expect(json_response[:case_report]['report_type']).to eq('original')
      end
    end

    context 'with skipping audit' do
      before do
        get "/api/v1/case_reports/#{case_report_1.id}", headers: headers.merge('X-Skip-Audit': 'true')
        case_report_1.reload.revision.reload
      end

      it 'should not create audit' do
        expect(Audit.count).to eq(0)
      end
    end
  end

  describe "GET #index" do
    before do
      case_report_1.reload
      case_report_2.reload
    end

    context 'return all case reports with the last revision' do
      before do
        get "/api/v1/case_reports", headers: headers
      end

      it 'should return two case reports' do
        expect(CaseReport.count).to eq(2)
      end

      it 'case_report_2' do
        expect(json_response[:case_reports].first.with_indifferent_access).to include(id: case_report_2.id,
                                                                                      datacenter_id: 1,
                                                                                      datacenter_name: 'test',
                                                                                      incident_id: case_report_2.incident_id,
                                                                                      incident_number: case_report_2.incident_number,
                                                                                      report_type: 'original',
                                                                                      revisions_count: 1)

        expect(json_response[:case_reports].first[:revision].with_indifferent_access).to include(responder_name: revision_2.responder_name,
                                                                                                 user_id: revision_2.user_id,
                                                                                                 name: revision_2.name,
                                                                                                 case_report_id: case_report_2.id,
                                                                                                 attachments: [],
                                                                                                 incident_address: {},
                                                                                                 content: {},
                                                                                                 patient_dob: nil,
                                                                                                 patient_name: nil)
      end

      it 'case_report_1' do
        get "/api/v1/case_reports", headers: headers
        expect(json_response[:case_reports].last.with_indifferent_access).to include(id: case_report_1.id,
                                                                                     datacenter_id: 1,
                                                                                     datacenter_name: 'test',
                                                                                     incident_id: case_report_1.incident_id,
                                                                                     incident_number: case_report_1.incident_number,
                                                                                     report_type: 'original',
                                                                                     revisions_count: 1)

        expect(json_response[:case_reports].last[:revision].with_indifferent_access).to include(responder_name: revision_1.responder_name,
                                                                                                user_id: revision_1.user_id,
                                                                                                name: revision_1.name,
                                                                                                case_report_id: case_report_1.id,
                                                                                                attachments: [],
                                                                                                incident_address: {},
                                                                                                content: {},
                                                                                                patient_dob: nil,
                                                                                                patient_name: nil)
      end
    end

    context 'return all case reports belongs to same incident with the last revision' do
      before do
        case_report_3.reload
        get "/api/v1/incidents/#{case_report_1.incident_id}/case_reports", headers: headers
      end

      it 'should return two case reports' do
        expect(json_response[:case_reports].count).to eq(2)
      end

      it 'case_report_2' do
        expect(json_response[:case_reports].first.with_indifferent_access).to include(id: case_report_2.id,
                                                                                      datacenter_id: 1,
                                                                                      datacenter_name: 'test',
                                                                                      incident_id: case_report_2.incident_id,
                                                                                      incident_number: case_report_2.incident_number,
                                                                                      report_type: 'original',
                                                                                      revisions_count: 1)

        expect(json_response[:case_reports].first[:revision].with_indifferent_access).to include(responder_name: revision_2.responder_name,
                                                                                                 user_id: revision_2.user_id,
                                                                                                 name: revision_2.name,
                                                                                                 case_report_id: case_report_2.id,
                                                                                                 attachments: [],
                                                                                                 incident_address: {},
                                                                                                 content: {},
                                                                                                 patient_dob: nil,
                                                                                                 patient_name: nil)
      end

      it 'case_report_1' do
        expect(json_response[:case_reports].last.with_indifferent_access).to include(id: case_report_1.id,
                                                                                     datacenter_id: 1,
                                                                                     datacenter_name: 'test',
                                                                                     incident_id: case_report_1.incident_id,
                                                                                     incident_number: case_report_1.incident_number,
                                                                                     report_type: 'original',
                                                                                     revisions_count: 1)

        expect(json_response[:case_reports].last[:revision].with_indifferent_access).to include(responder_name: revision_1.responder_name,
                                                                                                user_id: revision_1.user_id,
                                                                                                name: revision_1.name,
                                                                                                case_report_id: case_report_1.id,
                                                                                                attachments: [],
                                                                                                incident_address: {},
                                                                                                content: {},
                                                                                                patient_dob: nil,
                                                                                                patient_name: nil)
      end

      it 'should return meta' do
        expect(json_response[:meta].keys).to eq(%w[count page outset items last pages offset from to in prev next])
      end
    end
  end
end