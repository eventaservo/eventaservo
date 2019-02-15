# frozen_string_literal: true

FactoryBot.define do
  factory :evento, class: :event do
    title { 'Prova evento' }
    description { 'Prova evento priskribo' }
    content { 'Prov-informoj pri la prova evento' }
    association :user, factory: :uzanto
    deleted { false }
    city { Faker::Address.city }
    association :country, factory: :lando
    email { Faker::Internet.email }
    site { Faker::Internet.url }
    date_start { Time.zone.today }
    date_end { Time.zone.today }
    code { SecureRandom.urlsafe_base64(12) }

    trait :brazila do
      association :country, factory: [:lando, :brazilo]
    end

    trait :usona do
      association :country, factory: [:lando, :usono]
      city { 'New York' }
      address { '31 Ocean Parkway' }
    end

    trait :venonta do
      date_start { Time.zone.today + 1.day }
      date_end { Time.zone.today + 1.day }
    end
    trait :pasinta do
      date_start { Time.zone.today + 1.day }
      date_end { Time.zone.today - 1.day }
    end
  end
end
