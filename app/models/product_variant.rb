class ProductVariant < ApplicationRecord
  belongs_to :product

  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items

  has_many :order_items
  has_many :orders, through: :order_items

  validates :name, :sku, :price, :stock, presence: true
  validates :sku, uniqueness: true

  def full_name
    "#{product.title} - #{name}"
  end
end
