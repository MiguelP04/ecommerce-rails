class Category < ApplicationRecord
    has_ancestry
    has_many :products, dependent: :restrict_with_error
    has_many :postables, as: :postable, dependent: :destroy
    has_many :posts, through: :postables

    before_validation :generate_slug, on: :create

    validates :name, presence: true, uniqueness: true
    validates :slug, presence: true, uniqueness: true

    private

    def generate_slug
        self.slug ||= name.parameterize if name.present?
    end

end
