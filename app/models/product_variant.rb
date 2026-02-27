class ProductVariant < ApplicationRecord
  belongs_to :product

  has_many :variant_option_values, dependent: :destroy
  has_many :option_values, through: :variant_option_values

  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items

  has_many :order_items
  has_many :orders, through: :order_items

  validates :name, :sku, :price, :stock, presence: true
  validates :sku, uniqueness: true

  def full_name
    "#{product.title} - #{name}"
  end

  def specification
    option_values.map { |ov| "#{ov.option.name}: #{ov.name}" }.join(", ")
  end
end
