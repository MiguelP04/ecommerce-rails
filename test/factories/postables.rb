FactoryBot.define do
  factory :postable do
    association :post
    association :postable, factory: :product
  end
end
