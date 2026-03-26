class Post < ApplicationRecord
    has_rich_text :content
    has_one_attached :cover_image

    has_many :postables, dependent: :destroy
    has_many :products, through: :postables, source: :postable, source_type: "Product"
    has_many :categories, through: :postables, source: :postable, source_type: "Category"

    enum :status, { draft: 0, published: 1 }

    validates :title, presence: true
end
