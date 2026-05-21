require "swagger_helper"

RSpec.describe "API V1 Categories", type: :request do
  let(:admin) { create(:user, role: "admin") }
  let(:admin_token) { JwtService.encode(admin) }

  path "/api/v1/categories" do
    get("Listar categorias") do
      tags "Categorias"
      produces "application/json"

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response "200", "Lista de categorias" do
        let!(:category) { create(:category) }
        run_test!
      end
    end

    post("Crear categoria") do
      tags "Categorias"
      consumes "application/json"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string, example: "Electronica" },
              parent_id: { type: :integer, nullable: true, description: "ID de la categoria padre" }
            },
            required: [ :name ]
          }
        },
        required: [ :category ]
      }

      response "200", "Categoria creada" do
        let(:Authorization) { "Bearer #{admin_token}" }
        let(:body) { { category: { name: "New Category" } } }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        let(:body) { { category: { name: "Test" } } }
        run_test!
      end
    end
  end

  path "/api/v1/categories/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID de la categoria"

    get("Obtener categoria") do
      tags "Categorias"
      produces "application/json"

      response "200", "Categoria encontrada" do
        let(:category) { create(:category) }
        let(:id) { category.id }
        run_test!
      end

      response "404", "Categoria no encontrada" do
        let(:id) { 999 }
        run_test!
      end
    end

    patch("Actualizar categoria") do
      tags "Categorias"
      consumes "application/json"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string }
            }
          }
        },
        required: [ :category ]
      }

      response "200", "Categoria actualizada" do
        let(:Authorization) { "Bearer #{admin_token}" }
        let(:category) { create(:category) }
        let(:id) { category.id }
        let(:body) { { category: { name: "Updated Name" } } }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        let!(:existing_category) { create(:category) }
        let(:id) { existing_category.id }
        let(:body) { { category: { name: "Test" } } }
        run_test!
      end
    end

    delete("Eliminar categoria") do
      tags "Categorias"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      response "200", "Categoria eliminada" do
        let(:Authorization) { "Bearer #{admin_token}" }
        let(:category) { create(:category) }
        let(:id) { category.id }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        let!(:existing_category) { create(:category) }
        let(:id) { existing_category.id }
        run_test!
      end
    end
  end
end
