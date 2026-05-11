class UserMailer < ApplicationMailer
  default from: "noreply@tu-dominio.com"

  def password_reset(user, token)
    @user = user
    @reset_url = "#{Rails.application.credentials.frontend_url}/reset-password?token=#{token}"
    mail(to: user.email, subject: "Restablecer tu contraseña")
  end
end
