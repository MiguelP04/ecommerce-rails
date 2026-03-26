FactoryBot.define do
  factory :product do
    title { Faker::Commerce.product_name }
    association :category
  end
end
