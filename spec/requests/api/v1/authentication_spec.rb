require 'rails_helper'

RSpec.describe "Api::V1::Authentication", type: :request do
  let(:user) { create(:user) }

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
end
