class Api::V1::AuthController < ApiController
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

  private

  def user_params
    params.require(:user).permit(:email, :password, :name)
  end
end
