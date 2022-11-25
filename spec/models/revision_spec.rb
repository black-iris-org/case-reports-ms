require 'rails_helper'

RSpec.describe Revision, type: :model do
  describe 'associations' do
    it { should belong_to(:case_report) }
    it { should have_many(:audits) }
  end
end
