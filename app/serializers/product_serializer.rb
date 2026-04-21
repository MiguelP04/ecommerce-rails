class ProductSerializer
  def initialize(product, price_range = {})
    @product = product
    @price_range = price_range
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

    variants = @product.product_variants

    if price_filter_applied?
      variants = filter_variants_by_price(variants)
    end

    variants.map do |variant|
      {
        id: variant.id,
        name: variant.name,
        sku: variant.sku,
        price: variant.price,
        stock: variant.stock
      }
    end
  end

  def price_filter_applied?
    @price_range[:min_price].to_f > 0 || @price_range[:max_price].to_f > 0
  end

  def filter_variants_by_price(variants)
    min_price = @price_range[:min_price].to_f
    max_price = @price_range[:max_price].to_f

    variants.select do |variant|
      price = variant.price.to_f
      (min_price == 0 || price >= min_price) && (max_price == 0 || price <= max_price)
    end
  end
end
