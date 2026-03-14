FactoryBot.define do
  factory :option do
    name { Faker::Commerce.product_name }
  end
end
