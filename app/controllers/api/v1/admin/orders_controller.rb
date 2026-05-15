class Api::V1::Admin::OrdersController < Api::V1::Admin::BaseController
  def index
    orders = Order.includes(order_items: :product_variant).order(created_at: :desc)

    if params[:status].present?
      orders = orders.where(status: Order.statuses[params[:status]])
    end

    result = paginate(orders)
    render_success(
      result[:collection].map { |order| serialize_order(order) },
      result[:meta]
    )
  end

  def update
    order = Order.find_by(id: params[:id])
    return render_not_found("Order not found") unless order

    new_status = params[:status]
    return render_error("Invalid status") unless Order.statuses.key?(new_status)

    unless valid_transition?(order.status, new_status)
      return render_error("Cannot transition from #{order.status} to #{new_status}")
    end

    order.update!(status: new_status)
    render_success(serialize_order(order), { message: "Order updated to #{new_status}" })
  end

  private

  def serialize_order(order)
    {
      id: order.id,
      user_name: order.user.name,
      user_email: order.user.email,
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

  def valid_transition?(current, target)
    transitions = {
      "pending" => [ "paid", "cancelled" ],
      "paid" => [ "shipped" ],
      "shipped" => [ "delivered" ],
      "delivered" => [],
      "cancelled" => []
    }

    transitions[current].include?(target)
  end
end
