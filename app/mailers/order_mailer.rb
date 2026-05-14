class OrderMailer < ApplicationMailer
  default from: "noreply@tu-dominio.com"

  def confirmation(order)
    @order = order
    @user = order.user
    @items = order.order_items.includes(:product_variant)

    mail(to: @user.email, subject: "Confirmación de pedido ##{order.id}")
  end
end
