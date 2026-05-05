require "cgi"
require "net/http"

class OauthService
  GOOGLE_TOKENINFO_URL = "https://oauth2.googleapis.com/tokeninfo"

  def initialize(id_token)
    @id_token = id_token
  end

  def authenticate
    payload = verify_token
    return { error: "Invalid Google token" } unless payload

    user = find_or_create_user(payload)
    token = JwtService.encode(user)

    {
      token: token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        avatar_url: user.avatar_url
      }
    }
  end

  private

  def verify_token
    uri = URI("#{GOOGLE_TOKENINFO_URL}?id_token=#{CGI.escape(@id_token)}")
    response = Net::HTTP.get_response(uri)

    return nil unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue StandardError
    nil
  end

  def find_or_create_user(payload)
    user = User.find_by(email: payload["email"])

    if user
      user.update_column(:google_uid, payload["sub"]) if user.google_uid.blank?
      user
    else
      User.create!(
        email: payload["email"],
        google_uid: payload["sub"],
        name: payload["name"],
        avatar_url: payload["picture"],
        password: SecureRandom.urlsafe_base64
      )
    end
  end
end
