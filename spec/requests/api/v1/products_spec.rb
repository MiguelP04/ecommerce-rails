require 'rails_helper'

RSpec.describe "Api::V1::Products", type: :request do
  let!(:category) { create(:category) }
  let!(:product) { create(:product, category: category, title: "Elegant Watch", active: true) }
  let!(:product_inactive) { create(:product, category: category, title: "Old Watch", active: false) }
  let!(:admin) { create(:admin) }

  describe "GET /api/v1/products" do
    it "returns all products" do
      get "/api/v1/products"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
      expect(json["data"]).to be_an(Array)
    end

    it "returns paginated products" do
      get "/api/v1/products", params: { page: 1, per_page: 2 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["meta"]["page"]).to eq(1)
      expect(json["meta"]["per_page"]).to eq(2)
    end

    it "filters by category_id" do
      get "/api/v1/products", params: { category_id: category.id }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].first["category"]["id"]).to eq(category.id)
    end

    it "filters by active status" do
      get "/api/v1/products", params: { active: "true" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].all? { |p| p["active"] == true }).to be true
    end

    it "searches by query q" do
      get "/api/v1/products", params: { q: "Elegant" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].pluck("title").any? { |t| t.include?("Elegant") }).to be true
    end

    it "orders by field" do
      get "/api/v1/products", params: { order_by: "title", direction: "asc" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
    end

    it "filters by price range" do
      variant = create(:product_variant, product: product, price: 100)
      get "/api/v1/products", params: { min_price: 50, max_price: 150 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].pluck("id").include?(product.id)).to be true
    end
  end

  describe "GET /api/v1/products/:id" do
    it "returns a product" do
      get "/api/v1/products/#{product.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
      expect(json["data"]["id"]).to eq(product.id)
    end

    it "returns 404 for non-existent product" do
      get "/api/v1/products/99999"

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["success"]).to be false
    end
  end

  describe "POST /api/v1/products" do
    let(:token) { JwtService.encode(admin) }

    it "creates a product" do
      product_params = { product: { title: "New Product", category_id: category.id } }

      post "/api/v1/products", params: product_params, headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
      expect(json["data"]["title"]).to eq("New Product")
    end

    it "returns error when title is missing" do
      product_params = { product: { category_id: category.id } }

      post "/api/v1/products", params: product_params, headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects non-admin users" do
      user = create(:user)
      user_token = JwtService.encode(user)
      product_params = { product: { title: "Unauthorized Product", category_id: category.id } }

      post "/api/v1/products", params: product_params, headers: { "Authorization" => "Bearer #{user_token}" }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json["success"]).to be false
    end
  end

  describe "PATCH /api/v1/products/:id" do
    let(:token) { JwtService.encode(admin) }

    it "updates a product" do
      patch "/api/v1/products/#{product.id}", params: { product: { title: "Updated Title" } }, headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]["title"]).to eq("Updated Title")
    end
  end

  describe "DELETE /api/v1/products/:id" do
    let(:token) { JwtService.encode(admin) }

    it "deletes a product" do
      delete "/api/v1/products/#{product.id}", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
    end
  end
end
