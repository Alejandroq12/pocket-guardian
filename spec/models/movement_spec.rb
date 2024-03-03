require 'rails_helper'

RSpec.describe Movement, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      group = create(:group)
      expect(build(:movement, group:)).to be_valid
    end

    it 'is not valid without a name' do
      movement = build(:movement, name: nil)
      expect(movement).not_to be_valid
    end

    it 'is not valid without an amount' do
      movement = build(:movement, amount: nil)
      expect(movement).not_to be_valid
    end

    it 'is not valid without a group' do
      movement = build(:movement, group: nil)
      expect(movement).not_to be_valid
    end
  end
end
