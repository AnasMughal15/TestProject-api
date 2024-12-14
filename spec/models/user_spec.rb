require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Validations' do
    it 'is invalid without an email' do
      user = User.new(name: "John Doe", user_type: "developer")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid without a name' do
      user = User.new(email: "john@example.com", user_type: "developer")
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a user_type' do
      user = User.new(email: "john@example.com", name: "John Doe")
      expect(user).not_to be_valid
      expect(user.errors[:user_type]).to include("can't be blank")
    end
  end
end
