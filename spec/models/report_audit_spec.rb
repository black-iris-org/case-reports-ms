require 'rails_helper'

RSpec.describe ReportAudit, type: :model do
  describe 'associations' do
    it { should belong_to(:case_report).with_foreign_key(:auditable_id) }
  end

  describe 'delegation' do
    it { should delegate_method(:incident_id).to(:case_report) }
    it { should delegate_method(:incident_number).to(:case_report) }
    it { should delegate_method(:datacenter_name).to(:case_report) }
  end

  describe 'creation' do
    let(:case_report) { FactoryBot.create(:case_report) }
    let(:audit) { case_report.audits.first }

    it 'should create a new audit' do
      expect(audit)
        .to have_attributes(
              auditable_id: case_report.id,
              auditable_type: case_report.class.name,
              user_id: nil,
              username: nil,
              action: 'create',
              version: 1,
              comment: nil
            )
    end
  end
end
