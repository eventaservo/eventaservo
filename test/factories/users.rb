# frozen_string_literal: true

FactoryBot.define do
  factory :uzanto, class: :user do
    name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    city { Faker::Address.city }
    admin { false }
    password { Faker::Internet.password }
    confirmed_at { Time.now }
    association :country, factory: :lando

    trait :brazila do
      association :country, factory: [:lando, :brazilo]
    end
  end
end
