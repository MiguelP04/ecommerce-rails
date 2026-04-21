class Api::V1::ProductsController < ApiController
  before_action :set_product, only: [ :show, :update, :destroy ]

  def index
    products = Product.all

    products = apply_filters(products)
    products = apply_sorting(products)

    meta = paginate(products)
    price_range = { min_price: params[:min_price].to_f, max_price: params[:max_price].to_f }
    serialized = products.map { |product| ProductSerializer.new(product, price_range).as_json }

    render_success(serialized, meta)
  end

  def show
    render_success(ProductSerializer.new(@product).as_json)
  end

  def create
    product = Product.new(product_params)

    if product.save
      render_success(ProductSerializer.new(product).as_json)
    else
      render_error(product.errors.full_messages.join(", "))
    end
  end

  def update
    if @product.update(product_params)
      render_success(ProductSerializer.new(@product).as_json)
    else
      render_error(@product.errors.full_messages.join(", "))
    end
  end

  def destroy
    @product.destroy
    render_success({ message: "Product deleted" })
  end

  private

  def apply_filters(products)
    result = products

    if params[:category_id].present?
      result = result.where(category_id: params[:category_id])
    end

    if params[:active].present?
      result = result.where(active: params[:active] == "true")
    end

    if params[:q].present?
      search_term = "%#{params[:q]}%"
      result = result.where("title ILIKE ? OR description ILIKE ?", search_term, search_term)
    end

    if params[:min_price].present? || params[:max_price].present?
      result = apply_price_filters(result)
    end

    result
  end

  def apply_price_filters(products)
    min_price = params[:min_price].to_f
    max_price = params[:max_price].to_f

    products.joins(:product_variants)
           .where("product_variants.price >= ?", min_price)
           .where("product_variants.price <= ?", max_price)
  end

  def apply_sorting(products)
    return products unless params[:order_by].present?

    allowed_fields = %w[title created_at average_rating]
    field = params[:order_by].underscore
    direction = params[:direction] == "desc" ? "DESC" : "ASC"

    if allowed_fields.include?(field)
      products.order("#{field} #{direction}")
    else
      products
    end
  end

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found
  end

  def product_params
    params.require(:product).permit(:title, :description, :category_id, :active)
  end
end
