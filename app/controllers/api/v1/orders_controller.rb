class Api::V1::OrdersController < ApiController
  before_action :authenticate_user!

  def index
    result = paginate(current_user.orders.includes(order_items: :product_variant)
      .order(created_at: :desc))

    render_success(
      result[:collection].map { |order| serialize_order(order) },
      result[:meta]
    )
  end

  def show
    order = current_user.orders.includes(order_items: :product_variant).find_by(id: params[:id])
    return render_not_found("Order not found") unless order

    render_success(serialize_order(order))
  end

  def create
    result = CheckoutService.new(
      current_user,
      params[:address_id],
      payment_method: params[:payment_method],
      notes: params[:notes]
    ).call

    if result[:success]
      render_success(serialize_order(result[:order]), { message: "Order created" })
    else
      render_error(result[:error], status: :unprocessable_entity)
    end
  end

  def cancel
    order = current_user.orders.find_by(id: params[:id])
    return render_not_found("Order not found") unless order
    return render_error("Cannot cancel order that is not pending") unless order.pending?

    order.update!(status: :cancelled)
    render_success(serialize_order(order), { message: "Order cancelled" })
  end

  private

  def serialize_order(order)
    {
      id: order.id,
      total: order.total,
      status: order.status,
      payment_method: order.payment_method,
      items: order.order_items.map do |item|
        {
          id: item.id,
          variant_name: item.product_variant.name,
          product_name: item.product_variant.product.title,
          quantity: item.quantity,
          price: item.price,
          subtotal: item.price * item.quantity
        }
      end,
      created_at: order.created_at,
      updated_at: order.updated_at
    }
  end
end
