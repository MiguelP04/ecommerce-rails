class Order < ApplicationRecord
  belongs_to :user
  belongs_to :address, optional: true
  has_many :order_items, dependent: :destroy
  has_many :product_variants, through: :order_items

  enum :status, {
    pending: 0,
    paid: 1,
    shipped: 2,
    cancelled: 3,
    delivered: 4
  }
end
