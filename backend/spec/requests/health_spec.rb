require 'rails_helper'

RSpec.describe "Health API", type: :request do
  describe "GET /api/v1/health" do
    it "returns ok status" do
      get "/api/v1/health"

      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('ok')
    end
  end
end
