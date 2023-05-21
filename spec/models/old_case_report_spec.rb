require 'rails_helper'

RSpec.describe OldCaseReport, type: :model do
  let(:case_report) { FactoryBot.create(:case_report) }

  describe 'associations' do
    it { should have_many(:revisions) }
    it { should have_one(:revision) }
  end

  describe 'validation' do
    it "is not valid without a datacenter_id" do
      case_report = OldCaseReport.new(datacenter_id: nil)
      expect(case_report).to_not be_valid
    end

    it "is not valid without a incident_number" do
      case_report = OldCaseReport.new(incident_number: nil)
      expect(case_report).to_not be_valid
    end

    it "is not valid without a incident_id" do
      case_report = OldCaseReport.new(incident_id: nil)
      expect(case_report).to_not be_valid
    end

    it "is not valid without revisions on create" do
      case_report = OldCaseReport.new(revision_id: nil)
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
    it 'revision_id' do
      expect {
        case_report.update_attribute(:revision_id, 2)
      }.to raise_error(ActiveRecord::ActiveRecordError, 'revision_id is marked as readonly')
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

  describe 'accepts_nested_attributes_for' do
    it { should accept_nested_attributes_for :revisions }
  end

  describe 'scope' do
    context 'without_review_column' do
      it "should return case report with all columns except review_id" do
        case_report
        case_report_scoped = OldCaseReport.without_review_column.last
        expect { case_report_scoped.review_id }.to raise_error(NoMethodError)
      end
    end

    context 'with_revision' do
      it "should return case report that has revision" do
        case_report
        case_report_scoped = OldCaseReport.with_revision.last
        expect(case_report_scoped).to eq(case_report)
      end
    end

    context 'by_incident_id' do
      it "should return case report with given incident_id" do
        case_report
        case_report_scoped = OldCaseReport.by_incident_id(case_report.incident_id).last
        expect(case_report_scoped).to eq(case_report)
      end
    end
  end
end