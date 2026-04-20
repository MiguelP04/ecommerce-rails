class Api::V1::ProductsController < ApiController
  before_action :set_product, only: [ :show, :update, :destroy ]

  def index
    products = Product.all
    meta = paginate(products)
    serialized = products.map { |product| ProductSerializer.new(product).as_json }


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
  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found
  end

  def product_params
    params.require(:product).permit(:title, :description, :category_id, :active)
  end
end
