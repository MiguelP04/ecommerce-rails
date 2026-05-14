FactoryBot.define do
  factory :address do
    association :user
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip_code { Faker::Address.zip_code }
    country { Faker::Address.country }
    phone { Faker::PhoneNumber.phone_number }
    is_default { false }

    factory :default_address do
      is_default { true }
    end
  end
end
