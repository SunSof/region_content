require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    FactoryBot.create(:region, name: 'Москва')
  end

  subject(:user) { FactoryBot.create(:user, region: Region.find_by(name: 'Москва')) }

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:middle_name) }
    it { should validate_presence_of(:email) }

    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_inclusion_of(:role).in_array(['user', 'admin']) }

    it { should validate_length_of(:password).is_at_least(6).on(:create) }
    it { should validate_confirmation_of(:password) }
  end

  describe 'callbacks' do
    context 'before_validation' do
      it 'downcases email' do
        user.email = 'TEST@EXAMPLE.COM'
        user.valid?
        expect(user.email).to eq('test@example.com')
      end
    end
  end

  describe 'instance methods' do
    describe '#email_downcase' do
      it 'downcases the email' do
        user = User.new(email: 'TEST@EXAMPLE.COM')
        user.send(:email_downcase)
        expect(user.email).to eq('test@example.com')
      end
    end

    describe '#admin?' do
      it 'returns true if the role is admin' do
        user = User.new(role: 'admin')
        expect(user.send(:admin?)).to be_truthy
      end

      it 'returns false if the role is not admin' do
        user = User.new(role: 'user')
        expect(user.send(:admin?)).to be_falsey
      end
    end
  end
end
