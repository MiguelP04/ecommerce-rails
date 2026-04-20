class Product < ApplicationRecord
    belongs_to :category

    has_many :product_variants, dependent: :destroy
    has_many_attached :images
    has_many :postables, as: :postable, dependent: :destroy
    has_many :posts, through: :postables

    before_validation :generate_slug, on: :create

    acts_as_taggable_on :tags

    validates :title, :slug, presence: true
    validates :slug, uniqueness: true

    private
    def generate_slug
        self.slug ||= title.parameterize if title.present?
    end
end
