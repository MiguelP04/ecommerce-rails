FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    status { :draft }

    trait :published do
      status { :published }
    end
  end
end
