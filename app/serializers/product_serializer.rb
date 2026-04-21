class ProductSerializer
  def initialize(product)
    @product = product
  end

def as_json
    {
      id: @product.id,
      title: @product.title,
      description: @product.description,
      slug: @product.slug,
      active: @product.active,
      average_rating: @product.average_rating,
      category: category_data,
      tags: @product.tag_list,
      variants: variants_data,
      created_at: @product.created_at
    }
  end

  private

  def category_data
    return nil unless @product.category

    {
      id: @product.category.id,
      name: @product.category.name,
      slug: @product.category.slug
    }
  end

  def variants_data
    return [] unless @product.product_variants.any?

    @product.product_variants.map do |variant|
      {
        id: variant.id,
        name: variant.name,
        sku: variant.sku,
        price: variant.price,
        stock: variant.stock
      }
    end
  end
end
