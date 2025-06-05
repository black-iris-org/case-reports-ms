# spec/requests/audit_show_headers_spec.rb
require "rails_helper"

RSpec.describe "GET /show auditing", type: :request do
  # Create one report the GET will fetch
  let!(:report1) { FactoryBot.create(:case_report) }

  let(:header1) do
    {
      'Requester-Id':              '1',
      'Requester-Role':            'Admin',
      'Requester-Name':            'Name1',
      'Requester-First-Name':      'First Name 1',
      'Requester-Last-Name':       'Last Name 1',
      'Requester-Datacenter':      '1',
      'Requester-Datacenter-Name': 'test1',
      "Requester-Email":           "user1@example.com"
    }
  end

  let(:header2) do
    {
      'Requester-Id':              '2',
      'Requester-Role':            'Admin',
      'Requester-Name':            'Name2',
      'Requester-First-Name':      'First Name 2',
      'Requester-Last-Name':       'Last Name 2',
      'Requester-Datacenter':      '2',
      'Requester-Datacenter-Name': 'test2',
      "Requester-Email":           "user2@example.com"
    }
  end

  let(:valid_attributes) { { incident_number: 2, incident_id: 2, datacenter_id: 2, datacenter_name: 'test2', incident_at: Time.now,
                             report_type:     :amended, user_id: 2, responder_name: 'Responder Name 2', name: 'Name2' } }

  # Used to cache additional_details on class level inside auditor.rb
  it "does not leak audit data into the next request" do
    post "/api/v1/case_reports", params: { case_report: valid_attributes }, headers: header2
    get "/api/v1/case_reports/#{report1.id}", headers: header1

    all_audits = ReportAudit.all.order(:created_at)

    expect(all_audits.count).to eq(3)
    show_audit = all_audits.last

    expect(show_audit.action).to eq("show")
    expect(show_audit.first_name).to eq("First Name 1")
    expect(show_audit.last_name).to eq("Last Name 1")
  end
end
