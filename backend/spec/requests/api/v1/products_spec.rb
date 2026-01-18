require "rails_helper"

RSpec.describe "Products API", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: :admin) }
  let(:product) { create(:product) }

  let(:headers) do
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json"
    }
  end

  let(:admin_headers) do
    token = Warden::JWTAuth::UserEncoder.new.call(admin, :user, nil).first
    {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json"
    }
  end

  describe "GET /api/v1/products" do
    it "returns products" do
      get "/api/v1/products", headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/products" do
    it "returns error when params are invalid" do
      post "/api/v1/products",
          params: { product: { name: "" } }.to_json,
          headers: admin_headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
