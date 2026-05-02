require 'rails_helper'

RSpec.describe "Api::V1::Categories", type: :request do
  let!(:category) { create(:category) }
  let!(:admin) { create(:admin) }

  describe "GET /api/v1/categories" do
    it "returns all categories" do
      get "/api/v1/categories"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
    end
  end

  describe "GET /api/v1/categories/:id" do
    it "returns a category" do
      get "/api/v1/categories/#{category.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]["id"]).to eq(category.id)
    end
  end

  describe "POST /api/v1/categories" do
    let(:token) { JwtService.encode(admin) }

    it "creates a category" do
      category_params = { category: { name: "New Category" } }

      post "/api/v1/categories", params: category_params, headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
      expect(json["data"]["name"]).to eq("New Category")
    end
  end

  describe "PATCH /api/v1/categories" do
    let(:token) { JwtService.encode(admin) }

    it "updates a category" do
      patch "/api/v1/categories/#{category.id}", params: { category: { name: "Updated Category" } }, headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]["name"]).to eq("Updated Category")
    end
  end

  describe "DELETE /api/v1/categories/:id" do
    let(:token) { JwtService.encode(admin) }

    it "deletes a category" do
      delete "/api/v1/categories/#{category.id}", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
    end
  end
end
