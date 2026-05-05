require 'rails_helper'
require 'net/http'

RSpec.describe OauthService, type: :service do
  let(:valid_id_token) { "valid_google_id_token" }
  let(:google_payload) do
    {
      "email" => "user@example.com",
      "sub" => "google123",
      "name" => "Test User",
      "picture" => "https://example.com/avatar.jpg"
    }
  end

  describe "#authenticate" do
    context "with a valid Google token" do
      before do
        stub_google_tokeninfo(valid_id_token, google_payload)
      end

      it "creates a new user and returns JWT token" do
        result = described_class.new(valid_id_token).authenticate

        expect(result[:error]).to be_nil
        expect(result[:token]).to be_a(String)
        expect(result[:user][:email]).to eq("user@example.com")
        expect(result[:user][:name]).to eq("Test User")

        user = User.find_by(email: "user@example.com")
        expect(user).to be_present
        expect(user.google_uid).to eq("google123")
        expect(user.name).to eq("Test User")
        expect(user.avatar_url).to include("https://example.com/avatar.jpg")
      end

      it "finds existing user by email" do
        create(:user, email: "user@example.com", google_uid: nil)

        result = described_class.new(valid_id_token).authenticate

        expect(result[:error]).to be_nil
        expect(User.where(email: "user@example.com").count).to eq(1)
      end

      it "links google_uid to existing user without one" do
        user = create(:user, email: "user@example.com", google_uid: nil)

        result = described_class.new(valid_id_token).authenticate

        expect(result[:error]).to be_nil
        expect(user.reload.google_uid).to eq("google123")
      end

      it "returns user with existing google_uid" do
        create(:user, email: "user@example.com", google_uid: "google123")

        result = described_class.new(valid_id_token).authenticate

        expect(result[:user][:email]).to eq("user@example.com")
      end
    end

    context "with an invalid Google token" do
      before do
        stub_google_tokeninfo_invalid(valid_id_token)
      end

      it "returns an error" do
        result = described_class.new(valid_id_token).authenticate

        expect(result[:error]).to eq("Invalid Google token")
        expect(result[:token]).to be_nil
        expect(result[:user]).to be_nil
      end
    end

    context "when Google API raises an error" do
      before do
        stub_google_tokeninfo_error(valid_id_token)
      end

      it "returns an error" do
        result = described_class.new(valid_id_token).authenticate

        expect(result[:error]).to eq("Invalid Google token")
      end
    end
  end

  def stub_google_tokeninfo(id_token, payload)
    response = double("response")
    allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
    allow(response).to receive(:body).and_return(payload.to_json)
    allow(Net::HTTP).to receive(:get_response).and_return(response)
  end

  def stub_google_tokeninfo_invalid(id_token)
    response = double("response")
    allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
    allow(Net::HTTP).to receive(:get_response).and_return(response)
  end

  def stub_google_tokeninfo_error(id_token)
    allow(Net::HTTP).to receive(:get_response).and_raise(StandardError.new("Network error"))
  end
end
