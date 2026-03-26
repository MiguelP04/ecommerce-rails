FactoryBot.define do
  factory :user do
    google_uid { Faker::Internet.uuid }
  end
end
