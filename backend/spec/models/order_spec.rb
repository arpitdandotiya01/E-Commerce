require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:order_items).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, paid: 1, cancelled: 2) }
  end

  describe 'status methods' do
    let(:order) { create(:order) }

    it 'has pending status by default' do
      expect(order.status).to eq('pending')
      expect(order.pending?).to be true
      expect(order.paid?).to be false
      expect(order.cancelled?).to be false
    end

    it 'can be marked as paid' do
      order.paid!
      expect(order.status).to eq('paid')
      expect(order.paid?).to be true
    end

    it 'can be marked as cancelled' do
      order.cancelled!
      expect(order.status).to eq('cancelled')
      expect(order.cancelled?).to be true
    end
  end
end
