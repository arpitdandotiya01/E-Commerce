require "rails_helper"

RSpec.describe "Orders API", type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }

  describe "POST /api/v1/orders" do
    it "creates a new order for logged-in user" do
      post "/api/v1/orders", headers: auth_headers(user)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["status"]).to eq("pending")
    end
  end

  describe "POST /api/v1/orders/:id/add_item" do
    let(:order) { create(:order, user: user) }

    it "adds an item to the order" do
      post "/api/v1/orders/#{order.id}/add_item",
           params: { product_id: product.id, quantity: 2 }.to_json,
           headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      order.reload
      expect(order.order_items.count).to eq(1)
      expect(order.order_items.first.product).to eq(product)
      expect(order.order_items.first.quantity).to eq(2)
    end
  end
end
