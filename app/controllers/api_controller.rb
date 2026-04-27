class ApiController < ApplicationController
  attr_reader :current_user

  private

  def authenticate_user!
    token = extract_token_from_header
    return render_unauthorized("Missing token") unless token

    payload = decode_token(token)
    return render_unauthorized("Invalid token") unless payload

    @current_user = User.find_by(jti: payload["jti"])
    render_unauthorized("User not found") unless @current_user
  rescue ActiveRecord::RecordNotFound
    render_unauthorized("User not found")
  end

  def render_unauthorized(message)
    render json: { success: false, error: message }, status: :unauthorized
  end

  def extract_token_from_header
    header = request.headers["Authorization"]
    return nil unless header

    header.split(" ").last if header.start_with?("Bearer ")
  end

  def decode_token(token)
    JwtService.decode(token)
  end

  def devise_controller?
    false
  end

  def render_success(data = nil, meta = {})
    render json: { success: true, data: data, meta: meta }
  end

  def render_error(message, status: :unprocessable_entity)
    render json: { success: false, error: message }, status: status
  end

  def render_not_found(message = "Resource not found")
    render json: { success: false, error: message }, status: :not_found
  end

  def paginate(collection)
    page = params[:page].to_i.positive? ? params[:page].to_i : 1
    per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 20

    total = collection.try(:count) || collection.length
    {
      page: page,
      per_page: per_page,
      total: total,
      total_pages: (total.to_f / per_page).ceil
    }
  end
end
