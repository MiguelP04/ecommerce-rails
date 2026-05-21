require "swagger_helper"

RSpec.describe "API V1 Admin Orders", type: :request do
  let(:admin) { create(:user, role: "admin") }
  let(:admin_token) { JwtService.encode(admin) }
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:product) { create(:product, category: category) }
  let(:variant) { create(:product_variant, product: product, price: 100.0, stock: 5) }
  let(:address) { create(:address, user: user) }

  path "/api/v1/admin/orders" do
    get("Listar todas las ordenes (admin)") do
      tags "Admin - Ordenes"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      parameter name: :status, in: :query, type: :string, required: false,
                description: "Filtrar por estado (pending, paid, shipped, delivered, cancelled)"
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response "200", "Lista de ordenes" do
        let(:Authorization) { "Bearer #{admin_token}" }
        let(:cart) { create(:cart, user: user) }
        let!(:cart_item) { create(:cart_item, cart: cart, product_variant: variant, quantity: 2) }
        before do
          CheckoutService.new(user, address.id).call
        end
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path "/api/v1/admin/orders/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID de la orden"

    patch("Actualizar estado de la orden (admin)") do
      tags "Admin - Ordenes"
      consumes "application/json"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          status: {
            type: :string,
            description: "Nuevo estado de la orden",
            enum: [ "pending", "paid", "shipped", "delivered", "cancelled" ],
            example: "paid"
          }
        },
        required: [ :status ]
      }

      response "200", "Estado de la orden actualizado" do
        let(:Authorization) { "Bearer #{admin_token}" }
        let(:cart) { create(:cart, user: user) }
        let!(:cart_item) { create(:cart_item, cart: cart, product_variant: variant, quantity: 2) }
        let(:order) do
          result = CheckoutService.new(user, address.id).call
          result[:order]
        end
        let(:id) { order.id }
        let(:body) { { status: "paid" } }
        run_test!
      end

      response "422", "Transicion de estado invalida" do
        let(:Authorization) { "Bearer #{admin_token}" }
        let(:order) { create(:order, user: user, status: :pending) }
        let(:id) { order.id }
        let(:body) { { status: "shipped" } }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        let(:id) { 1 }
        let(:body) { { status: "paid" } }
        run_test!
      end
    end
  end
end
