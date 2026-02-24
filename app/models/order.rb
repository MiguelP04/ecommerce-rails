class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  enum status: {
    pending: 0,
    paid: 1,
    shipped: 2,
    cancelled: 3
  }
end
