require "rails_helper"

RSpec.describe PasswordResetService, type: :service do
  include ActiveSupport::Testing::TimeHelpers
  let(:user) { create(:user) }

  describe ".generate_token" do
    it "sets reset_password_token on the user" do
      token = described_class.generate_token(user)

      expect(token).to be_a(String)
      expect(token).not_to be_empty
      expect(user.reload.reset_password_token).to eq(token)
    end

    it "sets reset_password_token_expires_at to 15 minutes from now" do
      freeze_time = Time.zone.local(2026, 5, 5, 12, 0, 0)

      travel_to freeze_time do
        described_class.generate_token(user)

        expect(user.reload.reset_password_token_expires_at).to eq(freeze_time + 15.minutes)
      end
    end
  end

  describe ".reset_password" do
    context "with a valid token" do
      let!(:token) { described_class.generate_token(user) }
      let(:new_password) { "NewPassword123" }

      it "updates the password" do
        described_class.reset_password(token, new_password)

        expect(user.reload.authenticate(new_password)).to be_truthy
      end

      it "clears the reset token and expiration" do
        described_class.reset_password(token, new_password)

        expect(user.reload.reset_password_token).to be_nil
        expect(user.reload.reset_password_token_expires_at).to be_nil
      end

      it "returns success" do
        result = described_class.reset_password(token, new_password)

        expect(result[:success]).to be true
      end
    end

    context "with an invalid token" do
      it "returns an error" do
        result = described_class.reset_password("invalid_token", "NewPassword123")

        expect(result[:error]).to eq("Invalid token")
      end
    end

    context "with an expired token" do
      it "returns an error" do
        token = described_class.generate_token(user)

        user.update_columns(reset_password_token_expires_at: 1.minute.ago)

        result = described_class.reset_password(token, "NewPassword123")

        expect(result[:error]).to eq("Token expired")
      end
    end

    context "with a short password" do
      it "returns a validation error" do
        token = described_class.generate_token(user)

        result = described_class.reset_password(token, "short")

        expect(result[:error]).to be_present
        expect(result[:error]).to include("Password")
      end
    end
  end
end
