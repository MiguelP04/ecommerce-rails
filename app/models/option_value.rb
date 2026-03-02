class OptionValue < ApplicationRecord
  belongs_to :option
  has_many :variant_option_values, dependent: :destroy
  has_many :product_variants, through: :variant_option_values

  validates :name, presence: true

  def label
    "#{option.name}: #{name}"
  end
end
