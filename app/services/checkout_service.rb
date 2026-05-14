class CheckoutService
  def initialize(user, address_id, payment_method: nil, notes: nil)
    @user = user
    @address_id = address_id
    @payment_method = payment_method
    @notes = notes
  end

  def call
    cart = @user.cart
    return { error: "Cart is empty" } if cart.nil? || cart.cart_items.empty?

    items = cart.cart_items.includes(:product_variant)

    error = validate_stock(items)
    return { error: error } if error

    total = calculate_total(items)

    order = nil

    ActiveRecord::Base.transaction do
      order = Order.create!(
        user: @user,
        total: total,
        address_id: @address_id,
        payment_method: @payment_method,
        notes: @notes,
        status: :pending
      )

      items.each do |item|
        OrderItem.create!(
          order: order,
          product_variant: item.product_variant,
          quantity: item.quantity,
          price: item.product_variant.price
        )

        item.product_variant.decrement!(:stock, item.quantity)
      end

      cart.cart_items.destroy_all
    end

    send_confirmation_email(order)

    { success: true, order: order }
  end

  private

  def validate_stock(items)
    items.each do |item|
      variant = item.product_variant
      if item.quantity > variant.stock
        return "Insufficient stock for #{variant.full_name}. Available: #{variant.stock}"
      end
    end

    nil
  end

  def calculate_total(items)
    items.sum { |item| item.quantity * item.product_variant.price }
  end

  def send_confirmation_email(order)
    OrderMailer.confirmation(order).deliver_later
  rescue StandardError
    nil
  end
end
