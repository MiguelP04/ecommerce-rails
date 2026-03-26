FactoryBot.define do
  factory :product_variant do
    association :product
    name { Faker::Commerce.product_name }
    sku { Faker::Alphanumeric.alphanumeric(number: 8).upcase }
    price { Faker::Commerce.price }
    stock { 10 }
  end
end
