require 'rails_helper'

RSpec.describe "Api::V1::Carts", type: :request do
  let!(:user) { create(:user) }
  let!(:token) { JwtService.encode(user) }
  let!(:cart) { create(:cart, user: user) }
  let!(:category) { create(:category) }
  let!(:product) { create(:product, category: category) }
  let!(:variant) { create(:product_variant, product: product, price: 50) }
  let!(:cart_item) { create(:cart_item, cart: cart, product_variant: variant, quantity: 2) }

  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "GET /api/v1/cart" do
    it "returns the user's cart with items" do
      get "/api/v1/cart", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(cart.id)
      expect(json["item_count"]).to eq(2)
    end

    it "returns empty cart structure when user has no cart" do
      user_no_cart = create(:user)
      no_cart_token = JwtService.encode(user_no_cart)

      get "/api/v1/cart", headers: { "Authorization" => "Bearer #{no_cart_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to be_nil
      expect(json["items"]).to eq([])
      expect(json["total"]).to eq(0)
    end

    it "requires authentication" do
      get "/api/v1/cart"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/cart/items" do
    it "adds an item to the cart" do
      new_user = create(:user)
      new_cart = create(:cart, user: new_user)
      new_token = JwtService.encode(new_user)

      post "/api/v1/cart/items", params: { product_variant_id: variant.id, quantity: 3 }, headers: { "Authorization" => "Bearer #{new_token}" }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["items"].length).to eq(1)
      expect(json["items"].first["quantity"]).to eq(3)
    end

    it "increases quantity when same variant is added again" do
      post "/api/v1/cart/items", params: { product_variant_id: variant.id, quantity: 3 }, headers: headers
      post "/api/v1/cart/items", params: { product_variant_id: variant.id, quantity: 2 }, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["items"].first["quantity"]).to eq(7)
    end

    it "returns 404 when variant does not exist" do
      post "/api/v1/cart/items", params: { product_variant_id: 99999, quantity: 1 }, headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 when quantity is invalid" do
      post "/api/v1/cart/items", params: { product_variant_id: variant.id, quantity: 0 }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "requires authentication" do
      post "/api/v1/cart/items", params: { product_variant_id: variant.id, quantity: 1 }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /api/v1/cart/items/:id" do
    it "updates the quantity of a cart item" do
      patch "/api/v1/cart/items/#{cart_item.id}", params: { quantity: 5 }, headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["items"].first["quantity"]).to eq(5)
    end

    it "removes the item when quantity is 0 or less" do
      patch "/api/v1/cart/items/#{cart_item.id}", params: { quantity: 0 }, headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["items"]).to be_empty
    end

    it "returns 404 when cart item does not exist" do
      patch "/api/v1/cart/items/99999", params: { quantity: 1 }, headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when user has no cart" do
      user_no_cart = create(:user)
      no_cart_token = JwtService.encode(user_no_cart)

      patch "/api/v1/cart/items/#{cart_item.id}", params: { quantity: 1 }, headers: { "Authorization" => "Bearer #{no_cart_token}" }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/cart/items/:id" do
    it "removes an item from the cart" do
      delete "/api/v1/cart/items/#{cart_item.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["items"]).to be_empty
    end

    it "returns 404 when cart item does not exist" do
      delete "/api/v1/cart/items/99999", headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      delete "/api/v1/cart/items/#{cart_item.id}"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/cart" do
    it "clears all items from the cart" do
      delete "/api/v1/cart", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["items"]).to be_empty
      expect(json["total"]).to eq(0)
    end

    it "returns 404 when user has no cart" do
      user_no_cart = create(:user)
      no_cart_token = JwtService.encode(user_no_cart)

      delete "/api/v1/cart", headers: { "Authorization" => "Bearer #{no_cart_token}" }

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      delete "/api/v1/cart"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
