# frozen_string_literal: true

FactoryBot.define do
  factory :user, aliases: [:uzanto], class: :user do
    name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    city { Faker::Address.city }
    admin { false }
    password { Faker::Internet.password }
    confirmed_at { Time.now }
    country { Country.all.sample }
    webcal_token { Random.hex(4) }

    trait :brazila do
      country { Country.find_by(code: "br") }
    end

    trait :admin do
      admin { true }
    end
  end
end
