class Category < ApplicationRecord
    has_many :products, dependent: :restrict_with_error

    before_validation :generate_slug, on: :create

    validates :name, presence: true, uniqueness: true
    validates :slug, presence: true, uniqueness: true

    private

    def generate_slug
        self.slug ||= name.parameterize if name.present?
    end

end
