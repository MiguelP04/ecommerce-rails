require 'rails_helper'

RSpec.describe "Api::V1::Products", type: :request do
  let!(:category) { create(:category) }
  let!(:product) { create(:product, category: category) }

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
    it "creates a product" do
      product_params = { product: {title: "New Product", category_id: category.id } }

      post "/api/v1/products", params: product_params

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
      expect(json["data"]["title"]).to eq("New Product")
    end

    it "returns error when title is missing" do
      product_params = { product: { category_id: category.id} }

      post "/api/v1/products", params: product_params

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /api/v1/products/:id" do
    it "updates a product" do
      patch "/api/v1/products/#{product.id}", params: {product: { title: "Updated Title"}}

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]["title"]).to eq("Updated Title")
    end
  end

  describe "DELETE /api/v1/products/:id" do
    it "deletes a product" do
      delete "/api/v1/products/#{product.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
    end
  end
end







