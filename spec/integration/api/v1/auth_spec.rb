require "swagger_helper"

RSpec.describe "API V1 Auth", type: :request do
  let(:user) { create(:user) }
  let(:token) { JwtService.encode(user) }

  path "/api/v1/auth/signup" do
    post("Registrar usuario") do
      tags "Autenticacion"
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: "user@example.com" },
              password: { type: :string, example: "password123" },
              name: { type: :string, example: "Juan Perez" }
            },
            required: [ :email, :password ]
          }
        },
        required: [ :user ]
      }

      response "200", "Usuario registrado exitosamente" do
        let(:body) { { user: { email: "new@example.com", password: "password123", name: "Test" } } }
        run_test!
      end

      response "422", "Error de validacion" do
        let(:body) { { user: { email: "", password: "123", name: "" } } }
        run_test!
      end
    end
  end

  path "/api/v1/auth/login" do
    post("Iniciar sesion") do
      tags "Autenticacion"
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: "user@example.com" },
          password: { type: :string, example: "password123" }
        },
        required: [ :email, :password ]
      }

      response "200", "Inicio de sesion exitoso" do
        let(:body) { { email: user.email, password: "password123" } }
        run_test!
      end

      response "422", "Credenciales invalidas" do
        let(:body) { { email: "wrong@example.com", password: "wrong" } }
        run_test!
      end
    end
  end

  path "/api/v1/auth/google" do
    post("Iniciar sesion con Google") do
      tags "Autenticacion"
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          id_token: { type: :string, description: "Google ID token" }
        },
        required: [ :id_token ]
      }

      response "401", "Token de Google invalido" do
        let(:body) { { id_token: "invalid_token" } }
        run_test!
      end
    end
  end

  path "/api/v1/auth/me" do
    get("Obtener perfil del usuario actual") do
      tags "Autenticacion"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      response "200", "Perfil del usuario" do
        let(:Authorization) { "Bearer #{token}" }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path "/api/v1/auth/logout" do
    post("Cerrar sesion") do
      tags "Autenticacion"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      response "200", "Sesion cerrada exitosamente" do
        let(:Authorization) { "Bearer #{token}" }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path "/api/v1/auth/refresh" do
    post("Renovar token") do
      tags "Autenticacion"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      response "200", "Token renovado exitosamente" do
        let(:Authorization) { "Bearer #{token}" }
        run_test!
      end

      response "401", "No autorizado" do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path "/api/v1/auth/forgot_password" do
    post("Solicitar restablecimiento de contrasena") do
      tags "Autenticacion"
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: "user@example.com" }
        },
        required: [ :email ]
      }

      response "200", "Correo de restablecimiento enviado" do
        let(:body) { { email: user.email } }
        run_test!
      end
    end
  end

  path "/api/v1/auth/reset_password" do
    post("Restablecer contrasena") do
      tags "Autenticacion"
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          token: { type: :string, description: "Token de restablecimiento" },
          new_password: { type: :string, example: "newpassword123" }
        },
        required: [ :token, :new_password ]
      }

      response "422", "Token invalido o expirado" do
        let(:body) { { token: "invalid", new_password: "newpassword123" } }
        run_test!
      end
    end
  end
end
