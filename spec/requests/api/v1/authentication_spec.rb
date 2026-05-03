require 'rails_helper'

RSpec.describe "Api::V1::Authentication", type: :request do
  let(:user) { create(:user) }
  let(:token) { JwtService.encode(user) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "JWT token" do
    it "generates a valid token for user" do
      token = JwtService.encode(user)

      expect(token).to be_a(String)
      payload = JwtService.decode(token)
      expect(payload["jti"]).to eq(user.jti)
      expect(payload["user_id"]).to eq(user.id)
    end

    it "returns nil for invalid token" do
      result = JwtService.decode("invalid_token")

      expect(result).to be_nil
    end

    it "returns nil for tampered token" do
      token = JwtService.encode(user)
      tampered_token = token[0..-5] + "xxxxx"

      result = JwtService.decode(tampered_token)
      expect(result).to be_nil
    end
  end

  describe "GET /api/v1/auth/me" do
    it "returns current user profile" do
      get "/api/v1/auth/me", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
      expect(json["data"]["email"]).to eq(user.email)
      expect(json["data"]["role"]).to eq("user")
    end

    it "requires authentication" do
      get "/api/v1/auth/me"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/auth/logout" do
    it "regenerates jti and invalidates current token" do
      old_jti = user.jti

      post "/api/v1/auth/logout", headers: headers

      expect(response).to have_http_status(:ok)
      expect(user.reload.jti).not_to eq(old_jti)
    end

    it "makes the old token invalid" do
      post "/api/v1/auth/logout", headers: headers

      get "/api/v1/auth/me", headers: headers

      expect(response).to have_http_status(:unauthorized)
    end

    it "requires authentication" do
      post "/api/v1/auth/logout"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/auth/refresh" do
    it "generates a new token" do
      post "/api/v1/auth/refresh", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
      expect(json["data"]["token"]).to be_a(String)
    end

    it "regenerates jti so old token is invalid" do
      old_jti = user.jti

      post "/api/v1/auth/refresh", headers: headers
      json = JSON.parse(response.body)
      new_token = json["data"]["token"]

      expect(user.reload.jti).not_to eq(old_jti)

      get "/api/v1/auth/me", headers: { "Authorization" => "Bearer #{token}" }
      expect(response).to have_http_status(:unauthorized)

      get "/api/v1/auth/me", headers: { "Authorization" => "Bearer #{new_token}" }
      expect(response).to have_http_status(:ok)
    end

    it "requires authentication" do
      post "/api/v1/auth/refresh"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
