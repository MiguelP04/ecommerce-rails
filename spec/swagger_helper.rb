require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.3",
      info: {
        title: "Ecommerce Rails API",
        version: "v1",
        description: "API documentation for the Ecommerce Rails application"
      },
      servers: [
        {
          url: "http://localhost:3000",
          description: "Development server"
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: "JWT"
          }
        },
        schemas: {
          error_response: {
            type: :object,
            properties: {
              success: { type: :boolean },
              error: { type: :string }
            },
            required: [ :success, :error ]
          },
          success_response: {
            type: :object,
            properties: {
              success: { type: :boolean },
              data: { type: :object },
              meta: {
                type: :object,
                properties: {
                  page: { type: :integer },
                  per_page: { type: :integer },
                  total: { type: :integer },
                  total_pages: { type: :integer }
                }
              }
            },
            required: [ :success, :data ]
          },
          pagination_meta: {
            type: :object,
            properties: {
              page: { type: :integer },
              per_page: { type: :integer },
              total: { type: :integer },
              total_pages: { type: :integer }
            }
          },
          user: {
            type: :object,
            properties: {
              id: { type: :integer },
              email: { type: :string },
              name: { type: :string },
              role: { type: :string },
              created_at: { type: :string, format: "date-time" }
            }
          },
          product_variant: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              sku: { type: :string },
              price: { type: :string },
              stock: { type: :integer }
            }
          },
          category_ref: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              slug: { type: :string }
            }
          },
          product: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              description: { type: :string },
              slug: { type: :string },
              active: { type: :boolean },
              average_rating: { type: :number },
              category: { "$ref": "#/components/schemas/category_ref" },
              tags: { type: :array, items: { type: :string } },
              variants: { type: :array, items: { "$ref": "#/components/schemas/product_variant" } },
              created_at: { type: :string, format: "date-time" }
            }
          },
          category: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              slug: { type: :string },
              parent_id: { type: :integer, nullable: true },
              children: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string },
                    slug: { type: :string }
                  }
                }
              },
              created_at: { type: :string, format: "date-time" }
            }
          },
          cart_item_product: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              slug: { type: :string },
              cover_image_url: { type: :string, nullable: true }
            }
          },
          cart_item: {
            type: :object,
            properties: {
              id: { type: :integer },
              quantity: { type: :integer },
              product_variant: { "$ref": "#/components/schemas/product_variant" },
              product: { "$ref": "#/components/schemas/cart_item_product" },
              subtotal: { type: :number }
            }
          },
          cart: {
            type: :object,
            properties: {
              id: { type: :integer },
              user_id: { type: :integer },
              items: { type: :array, items: { "$ref": "#/components/schemas/cart_item" } },
              total: { type: :number },
              item_count: { type: :integer },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            }
          },
          order_item: {
            type: :object,
            properties: {
              id: { type: :integer },
              variant_name: { type: :string },
              product_name: { type: :string },
              quantity: { type: :integer },
              price: { type: :string },
              subtotal: { type: :number }
            }
          },
          order: {
            type: :object,
            properties: {
              id: { type: :integer },
              total: { type: :string },
              status: { type: :string },
              payment_method: { type: :string, nullable: true },
              items: { type: :array, items: { "$ref": "#/components/schemas/order_item" } },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            }
          },
          admin_order: {
            type: :object,
            properties: {
              id: { type: :integer },
              user_name: { type: :string },
              user_email: { type: :string },
              total: { type: :string },
              status: { type: :string },
              payment_method: { type: :string, nullable: true },
              items: { type: :array, items: { "$ref": "#/components/schemas/order_item" } },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            }
          },
          auth_token_response: {
            type: :object,
            properties: {
              success: { type: :boolean },
              data: {
                type: :object,
                properties: {
                  token: { type: :string },
                  user: { "$ref": "#/components/schemas/user" }
                }
              }
            }
          }
        }
      },
      paths: {}
    }
  }

  config.openapi_format = :yaml
end
