require "swagger_helper"

RSpec.describe "API V1 Carts", type: :request do
  let(:user) { create(:user) }
  let(:token) { JwtService.encode(user) }
  let(:category) { create(:category) }
  let(:product) { create(:product, category: category) }
  let(:variant) { create(:product_variant, product: product) }

  path "/api/v1/cart" do
    get("Mostrar carrito") do
      tags "Carrito"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      response "200", "Carrito del usuario" do
        let(:Authorization) { "Bearer #{token}" }
        let(:cart) { create(:cart, user: user) }
        let!(:cart_item) { create(:cart_item, cart: cart, product_variant: variant) }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        run_test!
      end
    end

    delete("Vaciar carrito") do
      tags "Carrito"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      response "200", "Carrito vaciado" do
        let(:Authorization) { "Bearer #{token}" }
        let(:cart) { create(:cart, user: user) }
        let!(:cart_item) { create(:cart_item, cart: cart, product_variant: variant) }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path "/api/v1/cart/items" do
    post("Agregar item al carrito") do
      tags "Carrito"
      consumes "application/json"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          product_variant_id: { type: :integer, example: 1 },
          quantity: { type: :integer, example: 2 }
        },
        required: [ :product_variant_id, :quantity ]
      }

      response "201", "Item agregado al carrito" do
        let(:Authorization) { "Bearer #{token}" }
        let(:body) { { product_variant_id: variant.id, quantity: 2 } }
        run_test!
      end

      response "404", "Variante no encontrada" do
        let(:Authorization) { "Bearer #{token}" }
        let(:body) { { product_variant_id: 999, quantity: 1 } }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        let(:body) { { product_variant_id: 1, quantity: 1 } }
        run_test!
      end
    end
  end

  path "/api/v1/cart/items/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID del item del carrito"

    patch("Actualizar cantidad del item") do
      tags "Carrito"
      consumes "application/json"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          quantity: { type: :integer, example: 3 }
        },
        required: [ :quantity ]
      }

      response "200", "Cantidad actualizada" do
        let(:Authorization) { "Bearer #{token}" }
        let(:cart) { create(:cart, user: user) }
        let(:cart_item) { create(:cart_item, cart: cart, product_variant: variant) }
        let(:id) { cart_item.id }
        let(:body) { { quantity: 3 } }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        let(:id) { 1 }
        let(:body) { { quantity: 1 } }
        run_test!
      end
    end

    delete("Eliminar item del carrito") do
      tags "Carrito"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      response "200", "Item eliminado del carrito" do
        let(:Authorization) { "Bearer #{token}" }
        let(:cart) { create(:cart, user: user) }
        let(:cart_item) { create(:cart_item, cart: cart, product_variant: variant) }
        let(:id) { cart_item.id }
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
