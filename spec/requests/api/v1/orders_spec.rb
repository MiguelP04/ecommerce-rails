require "rails_helper"

RSpec.describe "Api::V1::Orders", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:token) { JwtService.encode(user) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  let(:category) { create(:category) }
  let(:product) { create(:product, category: category) }
  let(:variant) { create(:product_variant, product: product, price: 100.0, stock: 5) }
  let(:address) { create(:address, user: user) }

  before do
    cart = create(:cart, user: user)
    create(:cart_item, cart: cart, product_variant: variant, quantity: 2)
  end

  describe "GET /api/v1/orders" do
    let!(:order) do
      result = CheckoutService.new(user, address.id).call
      result[:order]
    end

    it "returns user orders" do
      get "/api/v1/orders", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
      expect(json["data"].length).to eq(1)
      expect(json["data"].first["total"]).to eq("200.0")
    end

    it "requires authentication" do
      get "/api/v1/orders"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/orders/:id" do
    let!(:order) do
      result = CheckoutService.new(user, address.id).call
      result[:order]
    end

    it "returns order detail" do
      get "/api/v1/orders/#{order.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]["id"]).to eq(order.id)
      expect(json["data"]["items"].length).to eq(1)
    end

    it "returns 404 for another user's order" do
      other_user = create(:user)
      other_token = JwtService.encode(other_user)

      get "/api/v1/orders/#{order.id}", headers: { "Authorization" => "Bearer #{other_token}" }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/orders" do
    it "creates an order from cart" do
      post "/api/v1/orders", params: { address_id: address.id }, headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
      expect(json["data"]["total"]).to eq("200.0")
    end

    it "creates an order without address" do
      post "/api/v1/orders", params: {}, headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
    end

    it "requires authentication" do
      post "/api/v1/orders"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /api/v1/orders/:id/cancel" do
    let!(:order) do
      result = CheckoutService.new(user, address.id).call
      result[:order]
    end

    it "cancels a pending order" do
      patch "/api/v1/orders/#{order.id}/cancel", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]["status"]).to eq("cancelled")
    end

    it "cannot cancel a paid order" do
      order.update!(status: :paid)

      patch "/api/v1/orders/#{order.id}/cancel", headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "requires authentication" do
      patch "/api/v1/orders/#{order.id}/cancel"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "Admin orders" do
    let(:admin_token) { JwtService.encode(admin) }
    let(:admin_headers) { { "Authorization" => "Bearer #{admin_token}" } }

    before do
      CheckoutService.new(user, address.id).call
    end

    describe "GET /api/v1/admin/orders" do
      it "returns all orders for admin" do
        get "/api/v1/admin/orders", headers: admin_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["data"].length).to eq(1)
      end

      it "filters by status" do
        get "/api/v1/admin/orders", params: { status: "pending" }, headers: admin_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["data"].length).to eq(1)
      end

      it "rejects non-admin users" do
        get "/api/v1/admin/orders", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "PATCH /api/v1/admin/orders/:id" do
      let(:order) { Order.last }

      it "updates order status" do
        patch "/api/v1/admin/orders/#{order.id}",
              params: { status: "paid" },
              headers: admin_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["data"]["status"]).to eq("paid")
      end

      it "rejects invalid transitions" do
        patch "/api/v1/admin/orders/#{order.id}",
              params: { status: "shipped" },
              headers: admin_headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "rejects non-admin users" do
        patch "/api/v1/admin/orders/#{order.id}",
              params: { status: "paid" },
              headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
