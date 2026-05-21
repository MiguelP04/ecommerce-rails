class Address < ApplicationRecord
  belongs_to :user

  validates :street, :city, :state, :zip_code, :country, presence: true

  scope :default_first, -> { order(is_default: :desc) }
end
