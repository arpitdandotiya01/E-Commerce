require 'rails_helper'

RSpec.describe "Sessions API", type: :request do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

  describe "POST /api/v1/login" do
    context "with valid credentials" do
      it "returns a JWT token" do
        post "/api/v1/login", params: {
          user: {
            email: user.email,
            password: 'password123'
          }
        }

        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('token')
        expect(response_body).to have_key('user')
        expect(response_body['user']['email']).to eq(user.email)
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized" do
        post "/api/v1/login", params: {
          user: {
            email: user.email,
            password: 'wrongpassword'
          }
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
