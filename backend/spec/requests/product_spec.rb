require "rails_helper"

RSpec.describe "Products API", type: :request do
  let!(:product1) { create(:product, name: "Product 1", price: 100, stock_quantity: 10, active: true) }
  let!(:product2) { create(:product, name: "Product 2", price: 200, stock_quantity: 5, active: false) }
  let(:user) { create(:user) }
  let(:admin) { create(:user, email: 'admin@example.com', role: :admin) }
  let(:valid_product_params) do
    {
      product: {
        name: "New Product",
        description: "A great product",
        price: 150,
        stock_quantity: 20,
        active: true
      }
    }
  end

  describe "GET /api/v1/products" do
    it "returns all products" do
      get "/api/v1/products"

      expect(response).to have_http_status(:ok)
      products = JSON.parse(response.body)
      expect(products.length).to eq(2)

      product_names = products.map { |p| p["name"] }
      expect(product_names).to include("Product 1", "Product 2")
    end

    it "returns products with correct attributes" do
      get "/api/v1/products"

      expect(response).to have_http_status(:ok)
      products = JSON.parse(response.body)
      product = products.first

      expect(product).to have_key("id")
      expect(product).to have_key("name")
      expect(product).to have_key("description")
      expect(product).to have_key("price")
      expect(product).to have_key("stock_quantity")
      expect(product).to have_key("active")
      expect(product).to have_key("created_at")
      expect(product).to have_key("updated_at")
    end
  end

  describe "GET /api/v1/products/:id" do
    context "with valid product id" do
      it "returns the product" do
        get "/api/v1/products/#{product1.id}"

        expect(response).to have_http_status(:ok)
        product = JSON.parse(response.body)
        expect(product["name"]).to eq("Product 1")
        expect(product["price"]).to eq("100.0")
        expect(product["stock_quantity"]).to eq(10)
        expect(product["active"]).to eq(true)
      end
    end

    context "with invalid product id" do
      it "returns not found" do
        get "/api/v1/products/99999"

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/products" do
    context "with admin user" do
      it "creates a new product" do
        expect {
          post "/api/v1/products", params: valid_product_params.to_json,
                                   headers: auth_headers(admin)
        }.to change(Product, :count).by(1)

        expect(response).to have_http_status(:created)
        product = JSON.parse(response.body)
        expect(product["name"]).to eq("New Product")
        expect(product["price"]).to eq("150.0")
        expect(product["stock_quantity"]).to eq(20)
        expect(product["active"]).to eq(true)
      end

      context "with invalid params" do
        it "returns unprocessable entity for missing name" do
          invalid_params = valid_product_params.deep_merge(product: { name: "" })

          post "/api/v1/products", params: invalid_params.to_json,
                                   headers: auth_headers(admin)

          expect(response).to have_http_status(:unprocessable_content)
          errors = JSON.parse(response.body)
          expect(errors["errors"]).to include("Name can't be blank")
        end

        it "returns unprocessable entity for negative price" do
          invalid_params = valid_product_params.deep_merge(product: { price: -10 })

          post "/api/v1/products", params: invalid_params.to_json,
                                   headers: auth_headers(admin)

          expect(response).to have_http_status(:unprocessable_content)
          errors = JSON.parse(response.body)
          expect(errors["errors"]).to include("Price must be greater than or equal to 0")
        end

        it "returns unprocessable entity for negative stock quantity" do
          invalid_params = valid_product_params.deep_merge(product: { stock_quantity: -5 })

          post "/api/v1/products", params: invalid_params.to_json,
                                   headers: auth_headers(admin)

          expect(response).to have_http_status(:unprocessable_content)
          errors = JSON.parse(response.body)
          expect(errors["errors"]).to include("Stock quantity must be greater than or equal to 0")
        end
      end
    end

    context "with regular user" do
      it "returns forbidden" do
        post "/api/v1/products", params: valid_product_params.to_json,
                                 headers: auth_headers(user)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "without authentication" do
      it "returns unauthorized" do
        post "/api/v1/products", params: valid_product_params.to_json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /api/v1/products/:id" do
    let(:update_params) do
      {
        product: {
          name: "Updated Product",
          price: 250,
          stock_quantity: 15
        }
      }
    end

    context "with admin user" do
      it "updates the product" do
        put "/api/v1/products/#{product1.id}", params: update_params.to_json,
                                                headers: auth_headers(admin)

        expect(response).to have_http_status(:ok)
        product = JSON.parse(response.body)
        expect(product["name"]).to eq("Updated Product")
        expect(product["price"]).to eq("250.0")
        expect(product["stock_quantity"]).to eq(15)
      end
    end

    context "with regular user" do
      it "returns forbidden" do
        put "/api/v1/products/#{product1.id}", params: update_params.to_json,
                                                headers: auth_headers(user)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "without authentication" do
      it "returns unauthorized" do
        put "/api/v1/products/#{product1.id}", params: update_params.to_json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid product id" do
      it "returns not found" do
        put "/api/v1/products/99999", params: update_params.to_json,
                                      headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /api/v1/products/:id" do
    context "with admin user" do
      it "deletes the product" do
        expect {
          delete "/api/v1/products/#{product1.id}", headers: auth_headers(admin)
        }.to change(Product, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "with regular user" do
      it "returns forbidden" do
        delete "/api/v1/products/#{product1.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "without authentication" do
      it "returns unauthorized" do
        delete "/api/v1/products/#{product1.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid product id" do
      it "returns not found" do
        delete "/api/v1/products/99999", headers: auth_headers(admin)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
