FactoryBot.define do
  factory :option_value do
    association :option
    name { Faker::Commerce.color}
  end
end
