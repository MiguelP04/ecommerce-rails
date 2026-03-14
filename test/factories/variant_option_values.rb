FactoryBot.define do
  factory :variant_option_value do
    association :product_variant
    association :option_value
  end
end
