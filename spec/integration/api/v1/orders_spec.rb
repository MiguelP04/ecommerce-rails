require "swagger_helper"

RSpec.describe "API V1 Orders", type: :request do
  let(:user) { create(:user) }
  let(:token) { JwtService.encode(user) }
  let(:category) { create(:category) }
  let(:product) { create(:product, category: category) }
  let(:variant) { create(:product_variant, product: product, price: 100.0, stock: 5) }
  let(:address) { create(:address, user: user) }

  path "/api/v1/orders" do
    get("Listar ordenes del usuario") do
      tags "Ordenes"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response "200", "Lista de ordenes" do
        let(:Authorization) { "Bearer #{token}" }
        let(:cart) { create(:cart, user: user) }
        let!(:cart_item) { create(:cart_item, cart: cart, product_variant: variant, quantity: 2) }
        let!(:order) do
          result = CheckoutService.new(user, address.id).call
          result[:order]
        end
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        run_test!
      end
    end

    post("Crear orden desde el carrito") do
      tags "Ordenes"
      consumes "application/json"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      parameter name: :body, in: :body, required: false, schema: {
        type: :object,
        properties: {
          address_id: { type: :integer, description: "ID de la direccion de envio", example: 1 },
          payment_method: { type: :string, example: "credit_card" },
          notes: { type: :string, example: "Dejar en la puerta" }
        }
      }

      response "200", "Orden creada exitosamente" do
        let(:Authorization) { "Bearer #{token}" }
        let(:cart) { create(:cart, user: user) }
        let!(:cart_item) { create(:cart_item, cart: cart, product_variant: variant, quantity: 2) }
        let(:body) { { address_id: address.id } }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        let(:body) { { address_id: 1 } }
        run_test!
      end
    end
  end

  path "/api/v1/orders/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID de la orden"

    get("Obtener detalle de la orden") do
      tags "Ordenes"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      response "200", "Detalle de la orden" do
        let(:Authorization) { "Bearer #{token}" }
        let(:cart) { create(:cart, user: user) }
        let!(:cart_item) { create(:cart_item, cart: cart, product_variant: variant, quantity: 2) }
        let(:order) do
          result = CheckoutService.new(user, address.id).call
          result[:order]
        end
        let(:id) { order.id }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        let(:id) { 1 }
        run_test!
      end
    end
  end

  path "/api/v1/orders/{id}/cancel" do
    parameter name: :id, in: :path, type: :integer, description: "ID de la orden"

    patch("Cancelar orden") do
      tags "Ordenes"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      response "200", "Orden cancelada" do
        let(:Authorization) { "Bearer #{token}" }
        let(:cart) { create(:cart, user: user) }
        let!(:cart_item) { create(:cart_item, cart: cart, product_variant: variant, quantity: 2) }
        let(:order) do
          result = CheckoutService.new(user, address.id).call
          result[:order]
        end
        let(:id) { order.id }
        run_test!
      end

      response "422", "No se puede cancelar la orden" do
        let(:Authorization) { "Bearer #{token}" }
        let(:order) { create(:order, user: user, status: :paid) }
        let(:id) { order.id }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        let(:id) { 1 }
        run_test!
      end
    end
  end
end
