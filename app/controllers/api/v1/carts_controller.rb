class Api::V1::CartsController < ApiController
  before_action :authenticate_user!

  def show
    cart = current_user.cart || current_user.build_cart

    render json: CartSerializer.new(cart).as_json
  end

  def add_item
    cart = current_user.cart || current_user.build_cart
    cart.save!

    variant = ProductVariant.find_by(id: params[:product_variant_id])
    return render json: { error: "Product variant not found" }, status: :not_found unless variant

    quantity = params[:quantity].to_i
    return render json: { error: "Quantity must be greater than 0" }, status: :unprocessable_entity if quantity <= 0

    cart_item = CartItem.find_or_initialize_by(
      cart: cart,
      product_variant: variant
    ) do |item|
      item.quantity = 0
    end
    cart_item.quantity += quantity
    cart_item.save!

    render json: CartSerializer.new(cart.reload).as_json, status: :created
  end

  def update_item
    cart = current_user.cart
    return render json: { error: "Cart not found" }, status: :not_found unless cart

    cart_item = cart.cart_items.find_by(id: params[:id])
    return render json: { error: "Cart item not found" }, status: :not_found unless cart_item

    quantity = params[:quantity].to_i
    if quantity <= 0
      cart_item.destroy!
    else
      cart_item.update!(quantity: quantity)
    end

    render json: CartSerializer.new(cart.reload).as_json
  end

  def destroy_item
    cart = current_user.cart
    return render json: { error: "Cart not found" }, status: :not_found unless cart

    cart_item = cart.cart_items.find_by(id: params[:id])
    return render json: { error: "Cart item not found" }, status: :not_found unless cart_item

    cart_item.destroy!

    cart.reload
    render json: CartSerializer.new(cart).as_json
  end

  def clear
    cart = current_user.cart
    return render json: { error: "Cart not found" }, status: :not_found unless cart

    cart.cart_items.destroy_all

    render json: CartSerializer.new(cart.reload).as_json
  end

  private

  def cart_item_params
    params.permit(:product_variant_id, :quantity)
  end
end
