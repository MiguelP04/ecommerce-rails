require "swagger_helper"

RSpec.describe "API V1 Products", type: :request do
  let(:admin) { create(:user, role: "admin") }
  let(:admin_token) { JwtService.encode(admin) }
  let(:category) { create(:category) }

  path "/api/v1/products" do
    get("Listar productos") do
      tags "Productos"
      produces "application/json"

      parameter name: :page, in: :query, type: :integer, required: false, description: "Numero de pagina"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Elementos por pagina"
      parameter name: :q, in: :query, type: :string, required: false, description: "Buscar por titulo o descripcion"
      parameter name: :category_id, in: :query, type: :integer, required: false, description: "Filtrar por categoria"
      parameter name: :min_price, in: :query, type: :number, required: false, description: "Precio minimo"
      parameter name: :max_price, in: :query, type: :number, required: false, description: "Precio maximo"
      parameter name: :min_rating, in: :query, type: :number, required: false, description: "Calificacion minima"
      parameter name: :active, in: :query, type: :boolean, required: false, description: "Filtrar por activo"
      parameter name: :order_by, in: :query, type: :string, required: false, description: "Campo de ordenacion (title, created_at, average_rating)"
      parameter name: :direction, in: :query, type: :string, required: false, description: "Direccion (asc, desc)"

      response "200", "Lista de productos" do
        let(:category) { create(:category) }
        let!(:product) { create(:product, category: category) }
        let!(:variant) { create(:product_variant, product: product) }

        run_test!
      end
    end

    post("Crear producto") do
      tags "Productos"
      consumes "application/json"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              title: { type: :string, example: "Nuevo Producto" },
              description: { type: :string, example: "Descripcion del producto" },
              category_id: { type: :integer, example: 1 },
              active: { type: :boolean, example: true }
            },
            required: [ :title, :category_id ]
          }
        },
        required: [ :product ]
      }

      response "200", "Producto creado" do
        let(:Authorization) { "Bearer #{admin_token}" }
        let(:category) { create(:category) }
        let(:body) { { product: { title: "New Product", description: "Desc", category_id: category.id } } }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        let(:body) { { product: { title: "Test" } } }
        run_test!
      end
    end
  end

  path "/api/v1/products/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID del producto"

    get("Obtener producto") do
      tags "Productos"
      produces "application/json"

      response "200", "Producto encontrado" do
        let(:category) { create(:category) }
        let(:product) { create(:product, category: category) }
        let(:id) { product.id }
        let!(:variant) { create(:product_variant, product: product) }

        run_test!
      end

      response "404", "Producto no encontrado" do
        let(:id) { 999 }
        run_test!
      end
    end

    patch("Actualizar producto") do
      tags "Productos"
      consumes "application/json"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              active: { type: :boolean }
            }
          }
        },
        required: [ :product ]
      }

      response "200", "Producto actualizado" do
        let(:Authorization) { "Bearer #{admin_token}" }
        let(:category) { create(:category) }
        let(:product) { create(:product, category: category) }
        let(:id) { product.id }
        let(:body) { { product: { title: "Updated Title" } } }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        let!(:existing_product) { create(:product, category: create(:category)) }
        let(:id) { existing_product.id }
        let(:body) { { product: { title: "Test" } } }
        run_test!
      end
    end

    delete("Eliminar producto") do
      tags "Productos"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      response "200", "Producto eliminado" do
        let(:Authorization) { "Bearer #{admin_token}" }
        let(:category) { create(:category) }
        let(:product) { create(:product, category: category) }
        let(:id) { product.id }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        let!(:existing_product) { create(:product, category: create(:category)) }
        let(:id) { existing_product.id }
        run_test!
      end
    end
  end
end
