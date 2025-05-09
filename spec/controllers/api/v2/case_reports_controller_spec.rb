require 'rails_helper'

RSpec.describe Api::V2::CaseReportsController, type: :request do
  include JsonResponse

  let(:case_report_1) { FactoryBot.create(:case_report) }
  let(:case_report_2) { FactoryBot.create(:case_report) }
  let(:case_report_3) { FactoryBot.create(:case_report, incident_id: '2') }

  let(:valid_attributes) { { incident_number: 1, incident_id: 1, datacenter_id: 1, datacenter_name: 'test', incident_at: Time.now,
                             report_type:     :amended, user_id: 1, responder_name: 'test', name: 'test' } }
  let(:valid_attributes_2) { { incident_number: 1, incident_id: 1, datacenter_id: 1, incident_at: Time.now,
                               report_type:     :amended, user_id: 1, responder_name: 'test', name: 'test 2' } }

  let(:attachment_attributes_1) do
    {
      filename:     "test-file-1",
      checksum:     "XYFa0qq+ose3hxY01oMYbw==",
      byte_size:    30954,
      content_type: "application/pdf"
    }
  end

  let(:attachment_attributes_2) do
    {
      filename:     "test-file-2",
      checksum:     "MEI4ODU3RTA=",
      byte_size:    15931,
      content_type: "application/jpg"
    }
  end

  let(:headers) do
    {
      'Requester-Id':              '1',
      'Requester-Role':            'Admin',
      'Requester-Name':            Faker::Name.name,
      'Requester-Email':            Faker::Internet.email,
      'Requester-First-Name':      Faker::Name.first_name,
      'Requester-Last-Name':       Faker::Name.last_name,
      'Requester-Datacenter':      '1',
      'Requester-Datacenter-Name': 'test'
    }
  end

  describe 'POST #create' do
    context 'valid attributes' do
      before do
        post "/api/v2/case_reports", params: { case_report: valid_attributes }, headers: headers
      end

      it 'should create case_report' do
        expect(CaseReport.count).to eq(1)
        expect(json_response[:case_report].with_indifferent_access).to include(datacenter_id:    1,
                                                                               datacenter_name:  'test',
                                                                               incident_id:      valid_attributes[:incident_id],
                                                                               incident_number:  valid_attributes[:incident_number],
                                                                               report_type:      'original',
                                                                               revisions_count:  1,
                                                                               responder_name:   'test',
                                                                               user_id:          1,
                                                                               name:             'test',
                                                                               attachments:      [],
                                                                               incident_address: {},
                                                                               content:          {},
                                                                               patient_dob:      nil,
                                                                               patient_name:     nil)
      end

      it 'should create audit' do
        expect(ReportAudit.count).to eq(1)
        expect(ReportAudit.last.attributes.merge(ReportAudit.last.slice(:first_name, :last_name)).symbolize_keys)
          .to include(
                version:    1,
                user_id:    headers[:'Requester-Id'].to_i,
                username:   headers[:'Requester-Name'],
                first_name: headers[:'Requester-First-Name'],
                last_name:  headers[:'Requester-Last-Name'],
                user_type:  headers[:'Requester-Role'],
                action:     'create'
              )
      end

      it 'should return original as report_type' do
        expect(json_response[:case_report]['report_type']).to eq('original')
      end
    end

    context 'attachments' do
      let(:params) do
        { case_report: valid_attributes.merge(files_attributes: [attachment_attributes_2]) }
      end

      let(:report) { CaseReport.find(json_response.dig('case_report', 'id')) }

      before do
        post "/api/v2/case_reports", params: params, headers: headers
      end

      context 'should create valid attachment' do
        it('should be present') { expect(report.files).to be_present }
        it 'should match the initial attributes' do
          expect(report.files_blobs.first.attributes.with_indifferent_access)
            .to include(
                  filename:     "test-file-2",
                  checksum:     "MEI4ODU3RTA=",
                  byte_size:    15931,
                  content_type: "application/jpg"
                )
        end
      end

      it 'should return list of URLs for direct upload to S3' do
        expect(json_response.dig('case_report', 'direct_upload_urls')).to be_present
      end
    end
  end

  describe 'PUT #update' do
    before do
      case_report_1.reload
    end

    context 'valid update columns' do
      before do
        put "/api/v2/case_reports/#{case_report_1.id}",
            params:  { case_report: { user_id: 1, responder_name: 'test_2', name: 'test' } },
            headers: headers
        case_report_1.reload
      end

      it 'should update case_report' do
        expect(json_response[:case_report].symbolize_keys)
          .to include(datacenter_id:   1,
                      datacenter_name: 'test',
                      incident_id:     case_report_1.incident_id,
                      incident_number: case_report_1.incident_number,
                      report_type:     'amended',
                      revisions_count: 2)
      end

      it 'should create revision' do
        expect(case_report_1.revisions.size).to eq(2)
        expect(json_response[:case_report].symbolize_keys)
          .to include(responder_name:   'test_2',
                      user_id:          1,
                      name:             'test',
                      attachments:      [],
                      incident_address: {},
                      content:          {},
                      patient_dob:      nil,
                      patient_name:     nil)
      end

      it 'should create audit' do
        expect(ReportAudit.count).to eq(2)
      end

      it 'report_type is amended once updated' do
        expect(json_response[:case_report]['report_type']).to eq('amended')
      end
    end

    context 'can not update user_id column' do
      before do
        put "/api/v2/case_reports/#{case_report_1.id}",
            params:  { case_report: { user_id: 2, responder_name: 'test_2', name: 'test' } },
            headers: headers
        case_report_1.reload
      end

      it 'should return user_id and Requester-Id are the same' do
        expect(json_response[:case_report][:user_id]).to eq(headers[:'Requester-Id'].to_i)
      end
    end

    context 'attachments' do
      let!(:report) { FactoryBot.create(:case_report, with_sample_attachment: true) }

      context 'resetting attachments' do
        before do # resetting attachments
          put "/api/v2/case_reports/#{report.id}", params: params, headers: headers
          report.reload
        end

        let(:params) { { case_report: valid_attributes_2.merge(files_attributes: [attachment_attributes_1]) } }

        it 'should reset files attachments' do
          expect(report.files_blobs.pluck(:filename)).to eq([attachment_attributes_1[:filename]])
        end

        it 'should return list of URLs for direct upload to S3' do
          expect(json_response.dig('case_report', 'direct_upload_urls')).to be_present
        end
      end

      context 'adding attachments' do
        before do # adding attachments
          put "/api/v2/case_reports/#{report.id}", params: params, headers: headers
          report.reload
        end

        let(:params) { { case_report: valid_attributes_2.merge(add_files_attributes: [attachment_attributes_1]) } }

        it 'should add new attachment to the new revision' do
          expect(report.files_blobs.pluck(:filename)).to eq(['test-sample', attachment_attributes_1[:filename]])
        end

        it 'should return list of URLs for direct upload to S3' do
          expect(json_response.dig('case_report', 'direct_upload_urls')).to be_present
        end
      end

      context 'multi audit effect on attachments' do

        it 'attachments should not be affected by adding show/download audits' do
          # add show audit 1st time
          get "/api/v2/case_reports/#{report.id}", headers: headers
          expect(report.reload.files_blobs.pluck(:filename)).to eq(['test-sample'])

          # add download audit
          post "/api/v2/audits", headers: headers, params: { audit: { action: 'download', case_report_id: report.id } }
          expect(report.reload.files_blobs.pluck(:filename)).to eq(['test-sample'])

          # add show audit 1st time
          get "/api/v2/case_reports/#{report.id}", headers: headers
          expect(report.reload.files_blobs.pluck(:filename)).to eq(['test-sample'])
        end
      end

      context 'removing attachments' do
        before do # removing attachments
          put "/api/v2/case_reports/#{report.id}", params: params, headers: headers
          report.reload
        end

        let(:params) { { case_report: valid_attributes_2.merge(remove_files_attributes: ['test-sample']) } }

        it 'should add new attachment to the new revision' do
          expect(report.files_blobs.pluck(:filename)).to eq([])
        end

        it 'should return list of URLs for direct upload to S3' do
          expect(json_response.dig('case_report', 'direct_upload_urls')).to eq([])
        end
      end
    end
  end

  describe 'GET #show' do
    context 'return case_report' do
      it do
        get "/api/v2/case_reports/#{case_report_1.id}", headers: headers
        case_report_1.reload

        expect(json_response[:case_report])
          .to include(datacenter_id:    1,
                      datacenter_name:  'test',
                      incident_id:      case_report_1.incident_id,
                      incident_number:  case_report_1.incident_number,
                      report_type:      'original',
                      revisions_count:  1,
                      user_id:          1,
                      name:             'test',
                      attachments:      [],
                      incident_address: {},
                      content:          {},
                      patient_dob:      nil,
                      patient_name:     nil)
      end

      it 'should create audit' do
        expect do
          get "/api/v2/case_reports/#{case_report_1.id}", headers: headers
        end.to change { ReportAudit.count }.by(2)
      end

      it 'report_type still original once shown' do
        get "/api/v2/case_reports/#{case_report_1.id}", headers: headers

        expect(json_response[:case_report]['report_type']).to eq('original')
      end
    end

    context 'with skipping audit' do
      it 'should not create audit' do
        case_report_1
        expect do
          get "/api/v2/case_reports/#{case_report_1.id}", headers: headers.merge('X-Skip-Audit': 'true')
        end.not_to change { ReportAudit.count }
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
        get "/api/v2/case_reports", headers: headers
      end

      it 'should return two case reports' do
        expect(CaseReport.count).to eq(2)
      end

      it 'case_report_2' do
        expect(json_response[:case_reports].first.with_indifferent_access)
          .to include(id:               case_report_2.id,
                      datacenter_id:    1,
                      datacenter_name:  'test',
                      incident_id:      case_report_2.incident_id,
                      incident_number:  case_report_2.incident_number,
                      report_type:      'original',
                      revisions_count:  1,
                      responder_name:   case_report_2.responder_name,
                      user_id:          case_report_2.user_id,
                      name:             case_report_2.name,
                      incident_address: {})
      end

      it 'case_report_1' do
        get "/api/v2/case_reports", headers: headers
        expect(json_response[:case_reports].last.with_indifferent_access)
          .to include(id:               case_report_1.id,
                      datacenter_id:    1,
                      datacenter_name:  'test',
                      incident_id:      case_report_1.incident_id,
                      incident_number:  case_report_1.incident_number,
                      report_type:      'original',
                      revisions_count:  1,
                      responder_name:   case_report_1.responder_name,
                      user_id:          case_report_1.user_id,
                      name:             case_report_1.name,
                      incident_address: {})
      end
    end

    context 'return all case reports belongs to same incident with the last revision' do
      before do
        case_report_3.reload
        get "/api/v2/incidents/#{case_report_1.incident_id}/case_reports", headers: headers
      end

      it 'should return two case reports' do
        expect(json_response[:case_reports].count).to eq(2)
      end

      it 'case_report_2' do
        expect(json_response[:case_reports].first.with_indifferent_access)
          .to include(id:               case_report_2.id,
                      datacenter_id:    1,
                      datacenter_name:  'test',
                      incident_id:      case_report_2.incident_id,
                      incident_number:  case_report_2.incident_number,
                      report_type:      'original',
                      revisions_count:  1,
                      responder_name:   case_report_2.responder_name,
                      user_id:          case_report_2.user_id,
                      name:             case_report_2.name,
                      incident_address: {})
      end

      it 'case_report_1' do
        expect(json_response[:case_reports].last.with_indifferent_access)
          .to include(id:               case_report_1.id,
                      datacenter_id:    1,
                      datacenter_name:  'test',
                      incident_id:      case_report_1.incident_id,
                      incident_number:  case_report_1.incident_number,
                      report_type:      'original',
                      revisions_count:  1,
                      responder_name:   case_report_1.responder_name,
                      user_id:          case_report_1.user_id,
                      name:             case_report_1.name,
                      incident_address: {})
      end

      it 'should return meta' do
        expect(json_response[:meta].keys).to eq(%w[count page outset items last pages offset from to in prev next])
      end
    end
  end
end