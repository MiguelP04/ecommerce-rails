class Product < ApplicationRecord
    belongs_to :category
    has_many :cart_items
    has_many :carts, through: :cart_items

    before_validation :generate_slug, on: :create

    validates :title, presence: true
    validates :slug, presence: true, uniqueness: true

    private 

    def generate_slug
        self.slug ||= title.parameterize if title.present?
    end
end
