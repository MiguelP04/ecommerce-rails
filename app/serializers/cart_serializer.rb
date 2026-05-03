class CartSerializer
  def initialize(cart, options = {})
    @cart = cart
    @options = options
  end

  def as_json
    {
      id: @cart.id,
      user_id: @cart.user_id,
      items: cart_items_data,
      total: calculate_total,
      item_count: @cart.cart_items.sum(:quantity),
      created_at: @cart.created_at,
      updated_at: @cart.updated_at
    }
  end

  private

  def cart_items_data
    @cart.cart_items.map do |item|
      variant = item.product_variant
      product = variant.product

      {
        id: item.id,
        quantity: item.quantity,
        product_variant: {
          id: variant.id,
          name: variant.name,
          sku: variant.sku,
          price: variant.price,
          stock: variant.stock
        },
        product: {
          id: product.id,
          title: product.title,
          slug: product.slug,
          cover_image_url: cover_image_url(product)
        },
        subtotal: item.quantity * variant.price
      }
    end
  end

  def calculate_total
    @cart.cart_items.sum do |item|
      item.quantity * item.product_variant.price
    end
  end

  def cover_image_url(product)
    return nil unless product.cover_image.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      product.cover_image,
      only_path: true
    )
  end
end
