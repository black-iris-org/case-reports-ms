require 'rails_helper'

RSpec.describe OldAudit, type: :model do
  describe 'associations' do
    it { should belong_to(:revision) }
    it { should have_one(:case_report).through(:revision) }
  end

  describe 'delegation' do
    it { should delegate_method(:incident_id).to(:case_report) }
    it { should delegate_method(:incident_number).to(:case_report) }
    it { should delegate_method(:datacenter_name).to(:case_report) }
    it { should delegate_method(:id).to(:revision) }
  end

  describe 'enum' do
    it { should define_enum_for(:action).with_values(show: 0, create: 1, update: 2, download: 3).with_prefix(true) }
  end
end
