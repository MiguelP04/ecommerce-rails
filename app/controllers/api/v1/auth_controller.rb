class Api::V1::AuthController < ApiController
  before_action :authenticate_user!, only: [ :me, :logout, :refresh ]

  def login
    user = User.find_by(email: params[:email])
    return render_error("Invalid credentials") unless user&.authenticate(params[:password])

    token = JwtService.encode(user)
    render_success({ token: token, user: { id: user.id, email: user.email, name: user.name } })
  end

  def signup
    existing_user = User.find_by(email: params[:email])
    return render_error("Email already exists") if existing_user

    user = User.new(user_params)
    if user.save
      token = JwtService.encode(user)
      render_success({ token: token, user: { id: user.id, email: user.email, name: user.name } }, { message: "User created" })
    else
      render_error(user.errors.full_messages.join(", "))
    end
  end

  def me
    render_success(user_data(current_user))
  end

  def logout
    regenerate_jti(current_user)
    render_success({ message: "Successfully logged out" })
  end

  def refresh
    regenerate_jti(current_user)
    token = JwtService.encode(current_user)
    render_success({ token: token })
  end

  def google
    result = OauthService.new(params[:id_token]).authenticate

    if result[:error]
      render_error(result[:error], status: :unauthorized)
    else
      render_success({ token: result[:token], user: result[:user] })
    end
  end

  private

  def user_data(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      created_at: user.created_at
    }
  end

  def regenerate_jti(user)
    user.update_column(:jti, SecureRandom.uuid)
  end

  def user_params
    params.require(:user).permit(:email, :password, :name)
  end
end
