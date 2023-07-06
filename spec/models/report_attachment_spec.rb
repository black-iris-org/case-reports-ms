require 'rails_helper'

RSpec.describe ReportAttachment, type: :model do
  describe 'associations' do
    it { should belong_to(:case_report).with_foreign_key(:audit_id).optional }
    it { should have_many_attached(:files) }
  end
end
