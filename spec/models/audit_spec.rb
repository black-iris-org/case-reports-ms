require 'rails_helper'

RSpec.describe Audit, type: :model do
  describe 'associations' do
    it { should belong_to(:revision) }
  end
end
