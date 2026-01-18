require "rails_helper"

RSpec.describe "Cart Edge Cases", type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product, stock_quantity: 5) }
  let(:order) { create(:order, user: user, status: :pending) }

  before do
    create(:order_item, order: order, product: product, quantity: 2, price: product.price)
    order.update!(total_amount: 2 * product.price)
  end

  describe "POST /api/v1/orders/:id/checkout" do
    context "when product is deactivated before checkout" do
      before do
        product.update!(active: false)
      end

      it "returns an error indicating the product is unavailable" do
        post "/api/v1/orders/#{order.id}/checkout", headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)

        response_body = JSON.parse(response.body)
        expect(response_body["error"]).to include("Product #{product.name} is no longer available")

        order.reload
        expect(order.status).to eq("pending")
      end
    end

    context "when order is already paid" do
      before do
        order.update!(status: :paid)
      end

      it "returns forbidden because policy doesn't allow checkout on paid orders" do
        post "/api/v1/orders/#{order.id}/checkout", headers: auth_headers(user)

        expect(response).to have_http_status(:forbidden)

        order.reload
        expect(order.status).to eq("paid")
      end
    end

    context "when multiple products have mixed availability" do
      let(:inactive_product) { create(:product, stock_quantity: 10, active: false) }
      let(:active_product) { create(:product, stock_quantity: 10, active: true) }

      before do
        order.order_items.destroy_all
        create(:order_item, order: order, product: product, quantity: 1, price: product.price)
        create(:order_item, order: order, product: inactive_product, quantity: 1, price: inactive_product.price)
        create(:order_item, order: order, product: active_product, quantity: 1, price: active_product.price)
        order.update!(total_amount: product.price + inactive_product.price + active_product.price)
      end

      it "returns an error for the inactive product" do
        post "/api/v1/orders/#{order.id}/checkout", headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)

        response_body = JSON.parse(response.body)
        expect(response_body["error"]).to include("Product #{inactive_product.name} is no longer available")

        order.reload
        expect(order.status).to eq("pending")
        # Stock should not be reduced for any products
        product.reload
        active_product.reload
        inactive_product.reload
        expect(product.stock_quantity).to eq(5)
        expect(active_product.stock_quantity).to eq(10)
        expect(inactive_product.stock_quantity).to eq(10)
      end
    end

    context "when stock becomes insufficient during checkout" do
      before do
        # Simulate concurrent modification - another user buys the remaining stock
        product.update!(stock_quantity: 1) # Only 1 left, but we have 2 in cart
      end

      it "returns an error and rolls back the transaction" do
        post "/api/v1/orders/#{order.id}/checkout", headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)

        response_body = JSON.parse(response.body)
        expect(response_body["error"]).to include("Insufficient stock for product #{product.name}")

        order.reload
        expect(order.status).to eq("pending")
        product.reload
        expect(product.stock_quantity).to eq(1) # Stock unchanged
      end
    end
  end

  describe "POST /api/v1/orders/:id/add_item" do
    context "when adding inactive product" do
      before do
        product.update!(active: false)
      end

      it "returns an error" do
        post "/api/v1/orders/#{order.id}/add_item",
             params: { product_id: product.id, quantity: 1 }.to_json,
             headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)

        response_body = JSON.parse(response.body)
        expect(response_body["error"]).to include("Product is no longer available")
      end
    end

    context "when adding product with insufficient stock" do
      before do
        product.update!(stock_quantity: 0)
      end

      it "returns an error" do
        post "/api/v1/orders/#{order.id}/add_item",
             params: { product_id: product.id, quantity: 1 }.to_json,
             headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)

        response_body = JSON.parse(response.body)
        expect(response_body["error"]).to include("Insufficient stock")
      end
    end
  end
end
