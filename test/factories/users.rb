FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    name { Faker::Name.name }
    google_uid { Faker::Internet.uuid }
    role { "user" }

    factory :admin do
      role { "admin" }
    end
  end
end
