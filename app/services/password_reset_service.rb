class PasswordResetService
  EXPIRATION_TIME = 15.minutes

  def self.generate_token(user)
    token = SecureRandom.urlsafe_base64
    user.update_columns(
      reset_password_token: token,
      reset_password_token_expires_at: EXPIRATION_TIME.from_now
    )
    token
  end

  def self.reset_password(token, new_password)
    user = User.find_by(reset_password_token: token)
    return { error: "Invalid token" } unless user
    return { error: "Token expired" } if user.reset_password_token_expires_at < Time.current

    if user.update(
      password: new_password,
      reset_password_token: nil,
      reset_password_token_expires_at: nil
    )
      { success: true }
    else
      { error: user.errors.full_messages.join(", ") }
    end
  end
end
