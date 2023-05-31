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
end
