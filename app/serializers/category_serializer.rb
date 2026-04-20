class CategorySerializer
  def initialize(category)
    @category = category
  end

  def as_json
    {
      id: @category.id,
      name: @category.name,
      slug: @category.slug,
      parent_id: @category.parent_id,
      children: children_data,
      created_at: @category.created_at
    }
  end

  private
  def children_data
    return [] unless @category.children.any?

    @category.children.map do |child|
      {
        id: child.id,
        name: child.name,
        slug: child.slug
      }
    end
  end
end
