require "rails_helper"

RSpec.describe "Orders API Checkout", type: :request do
  let(:user) { create(:user) }
  let(:product1) { create(:product, stock_quantity: 10) }
  let(:product2) { create(:product, stock_quantity: 5) }
  let(:order) { create(:order, user: user, status: :pending) }

  before do
    # Create order items
    create(:order_item, order: order, product: product1, quantity: 2, price: product1.price)
    create(:order_item, order: order, product: product2, quantity: 1, price: product2.price)
    # Update order total
    order.update!(total_amount: (2 * product1.price) + (1 * product2.price))
  end

  describe "POST /api/v1/orders/:id/checkout" do
    context "with valid order and sufficient stock" do
      it "completes the checkout successfully" do
        expect {
          post "/api/v1/orders/#{order.id}/checkout", headers: auth_headers(user)
        }.to have_enqueued_job(OrderConfirmationJob).with(order.id)

        expect(response).to have_http_status(:ok)

        response_body = JSON.parse(response.body)
        expect(response_body["message"]).to eq("Order placed successfully")
        expect(response_body["order_id"]).to eq(order.id)
        expect(response_body["status"]).to eq("paid")

        # Verify order status changed
        order.reload
        expect(order.status).to eq("paid")

        # Verify stock was reduced
        product1.reload
        product2.reload
        expect(product1.stock_quantity).to eq(8) # 10 - 2
        expect(product2.stock_quantity).to eq(4) # 5 - 1
      end
    end

    context "with insufficient stock" do
      before do
        product1.update!(stock_quantity: 1) # Less than required 2
      end

      it "returns an error and doesn't update the order" do
        post "/api/v1/orders/#{order.id}/checkout", headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)

        response_body = JSON.parse(response.body)
        expect(response_body["error"]).to include("Insufficient stock")

        # Verify order status didn't change
        order.reload
        expect(order.status).to eq("pending")

        # Verify stock wasn't reduced
        product1.reload
        expect(product1.stock_quantity).to eq(1)
      end
    end

    context "with unauthorized user" do
      let(:other_user) { create(:user) }

      it "returns not found" do
        post "/api/v1/orders/#{order.id}/checkout", headers: auth_headers(other_user)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "with non-existent order" do
      it "returns not found" do
        post "/api/v1/orders/99999/checkout", headers: auth_headers(user)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end