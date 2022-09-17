# frozen_string_literal: true

FactoryBot.define do
  factory :evento, class: :event do
    title { 'Prova evento' }
    description { 'Prova evento priskribo' }
    content { 'Prov-informoj pri la prova evento' }
    association :user, factory: :uzanto
    deleted { false }
    city { Faker::Address.city }
    country { Country.all.sample }
    email { Faker::Internet.email }
    site { Faker::Internet.url }
    date_start { Time.zone.today }
    date_end { Time.zone.today }
    code { SecureRandom.urlsafe_base64(12) }
    time_zone { Faker::Address.time_zone }
    short_url { Faker::Food.fruits + '_' + rand(1000).to_s }
    uuid { Faker::Internet.uuid }

    trait :brazila do
      country { Country.find_by(code: "br") }
    end

    trait :usona do
      country { Country.find_by(code: "us") }
      city { 'New York' }
      address { '31 Ocean Parkway' }
    end

    trait :japana do
      country { Country.find_by(code: "jp") }
      city { 'Tokyo' }
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
