require 'rails_helper'

RSpec.describe CaseReport, type: :model do
  describe 'associations' do
    it { should have_many(:revisions) }
  end
end
