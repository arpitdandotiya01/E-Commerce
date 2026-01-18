require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
  end

  describe 'associations' do
    it { should have_many(:orders).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(user: 0, admin: 1) }
  end

  describe '#admin?' do
    context 'when user has admin role' do
      let(:admin_user) { create(:user, role: :admin) }

      it 'returns true' do
        expect(admin_user.admin?).to be true
      end
    end

    context 'when user has user role' do
      let(:regular_user) { create(:user, role: :user) }

      it 'returns false' do
        expect(regular_user.admin?).to be false
      end
    end
  end

  describe '#set_default_role' do
    context 'when role is not set' do
      let(:user) { build(:user, role: nil) }

      it 'sets role to user' do
        user.save
        expect(user.user?).to be true
      end
    end

    context 'when role is already set' do
      let(:user) { build(:user, role: :admin) }

      it 'does not change the role' do
        user.save
        expect(user.admin?).to be true
      end
    end
  end
end
