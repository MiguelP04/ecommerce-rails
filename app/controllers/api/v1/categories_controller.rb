class Api::V1::CategoriesController < ApiController
  before_action :set_category, only: [ :show, :update, :destroy ]
  before_action :authenticate_admin!, only: [ :create, :update, :destroy ]

  def index
    categories = Category.all
    meta = paginate(categories)
    serialized = categories.map { |category| CategorySerializer.new(category).as_json }

    render_success(serialized, meta)
  end

  def show
    render_success(CategorySerializer.new(@category).as_json)
  end

  def create
    category = Category.new(category_params)

    if category.save
      render_success(CategorySerializer.new(category).as_json)
    else
      render_error(category.errors.full_messages.join(", "))
    end
  end

  def update
    if @category.update(category_params)
      render_success(CategorySerializer.new(@category).as_json)
    else
      render_error(@category.errors.full_messages.join(", "))
    end
  end

  def destroy
    @category.destroy
    render_success({ message: "Category deleted" })
  end

  private
  def set_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found
  end

  def category_params
    params.require(:category).permit(:name, :parent_id)
  end
end
