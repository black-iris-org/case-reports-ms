require 'rails_helper'

RSpec.describe Revision, type: :model do
  let(:revision) { FactoryBot.create(:revision) }
  let(:revision_duplication) { FactoryBot.create(:revision, revision.attributes.except('id')) }

  describe 'associations' do
    it { should belong_to(:case_report) }
    it { should have_many(:audits) }
  end

  describe 'validation' do
    it "is not valid without a user_id" do
      revision = Revision.new(user_id: nil)
      expect(revision).to_not be_valid
    end

    it "is not valid without a responder_name" do
      revision = Revision.new(responder_name: nil)
      expect(revision).to_not be_valid
    end

    it "is not valid without a name" do
      revision = Revision.new(name: nil)
      expect(revision).to_not be_valid
    end

    it "validate_not_identical" do
      revision_duplication.validate
      expect(revision_duplication.errors).to_not eq []
    end
  end

  describe 'constant' do
    it 'have JSONB_COLUMNS constant' do
      expect(described_class::JSONB_COLUMNS).to eq({ incident_address: [:name, lat_lng: { coordinates: [] }],
                                                     content: {} })
    end

    it 'have PRIMITIVE_COLUMNS constant' do
      expect(described_class::PRIMITIVE_COLUMNS).to eq(%w[responder_name patient_name patient_dob name])
    end
  end

  describe "scope" do
    context 'with_case_report' do
      it "should return revision that belongs to case report" do
        revision
        scoped_revision = Revision.with_case_report.last
        expect(scoped_revision).to eq(revision)
      end
    end
  end

  describe 'callbacks' do
    context 'set default' do
      it 'should set empty hash for content and incident_address' do
        revision
        expect(revision.content).to eq({})
        expect(revision.incident_address).to eq({})
      end
    end
  end
end
