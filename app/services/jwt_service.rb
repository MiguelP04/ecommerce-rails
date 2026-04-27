class JwtService
  def self.encode(user)
    payload = {
      jti: user.jti,
      user_id: user.id,
      exp: 7.days.from_now.to_i
    }

    secret = Rails.application.credentials.jwt_secret || "default_secret_change_in_production"
    JWT.encode(payload, secret, "HS256")
  end

  def self.decode(token)
    secret = Rails.application.credentials.jwt_secret || "default_secret_change_in_production"
    JWT.decode(token, secret, true, algorithm: "HS256").first
  rescue JWT::DecodeError
    nil
  end
end
