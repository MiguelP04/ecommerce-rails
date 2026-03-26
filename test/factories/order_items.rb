FactoryBot.define do
  factory :order_item do
    association :order
    association :product_variant
  end
end
