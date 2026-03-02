class VariantOptionValue < ApplicationRecord
  belongs_to :product_variant
  belongs_to :option_value

  validates :option_value_id, uniqueness: { scope: :product_variant_id, message: "ya existe para esta variante" }
end
