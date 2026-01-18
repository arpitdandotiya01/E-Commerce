require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:product) }
  end

  describe 'calculations' do
    let(:product) { create(:product, price: 100) }
    let(:order) { create(:order) }
    let(:order_item) { create(:order_item, order: order, product: product, quantity: 2, price: 100) }

    it 'calculates total correctly' do
      expect(order_item.quantity * order_item.price).to eq(200)
    end
  end
end
