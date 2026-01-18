require "rails_helper"

RSpec.describe "Orders API", type: :request do
  let(:user) { create(:user) }

  describe "POST /api/v1/orders" do
    it "creates a new order for logged-in user" do
      post "/api/v1/orders", headers: auth_headers(user)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["status"]).to eq("pending")
    end
  end
end
