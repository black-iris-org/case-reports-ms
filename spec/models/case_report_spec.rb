require 'rails_helper'

RSpec.describe CaseReport, type: :model do
  let(:case_report) { FactoryBot.create(:case_report) }

  describe 'associations' do
    it { should have_many(:audits) }
    # it { should have_one(:revision) }
  end

  describe 'validation' do
    it "is not valid without a datacenter_id" do
      case_report = CaseReport.new(datacenter_id: nil)
      expect(case_report).to_not be_valid
    end

    it "is not valid without a incident_number" do
      case_report = CaseReport.new(incident_number: nil)
      expect(case_report).to_not be_valid
    end

    it "is not valid without a incident_id" do
      case_report = CaseReport.new(incident_id: nil)
      expect(case_report).to_not be_valid
    end
  end

  describe 'enum' do
    it { should define_enum_for(:report_type).with_values([:original, :amended]) }
  end

  describe 'attr_readonly' do
    before do
      case_report
    end

    it 'revisions_count' do
      expect {
        case_report.update_attribute(:revisions_count, 2)
      }.to raise_error(ActiveRecord::ActiveRecordError, 'revisions_count is marked as readonly')
    end

    it 'report_type' do
      expect {
        case_report.update_attribute(:report_type, 'test')
      }.to raise_error(ActiveRecord::ActiveRecordError, 'report_type is marked as readonly')
    end

    it 'incident_number' do
      expect {
        case_report.update_attribute(:incident_number, 2)
      }.to raise_error(ActiveRecord::ActiveRecordError, 'incident_number is marked as readonly')
    end

    it 'incident_at' do
      expect {
        case_report.update_attribute(:incident_at, DateTime.now)
      }.to raise_error(ActiveRecord::ActiveRecordError, 'incident_at is marked as readonly')
    end

    it 'datacenter_id' do
      expect {
        case_report.update_attribute(:datacenter_id, 2)
      }.to raise_error(ActiveRecord::ActiveRecordError, 'datacenter_id is marked as readonly')
    end

    it 'datacenter_id' do
      expect {
        case_report.update_attribute(:datacenter_name, 'test_2')
      }.to raise_error(ActiveRecord::ActiveRecordError, 'datacenter_name is marked as readonly')
    end
  end

  describe 'scope' do
    context 'by_incident_id' do
      it "should return case report with given incident_id" do
        case_report
        case_report_scoped = CaseReport.by_incident_id(case_report.incident_id).last
        expect(case_report_scoped).to eq(case_report)
      end
    end
  end
end