# frozen_string_literal: true

FactoryBot.define do
  factory :event, aliases: [:evento], class: :event do
    book = Faker::Book
    address = Faker::Address

    title { book.title }
    description { "Ni legos libron de #{book.author}" }
    enhavo { Faker::Lorem.paragraph(sentence_count: 20) }
    association :user, factory: :uzanto
    deleted { false }

    address { address.street_address }
    city { address.city }
    country { Country.by_code(address.country_code) || Country.by_code("BR") }
    latitude { address.latitude }
    longitude { address.longitude }

    email { Faker::Internet.email }
    site { Faker::Internet.url }
    date_start { Faker::Time.between(from: DateTime.now, to: DateTime.now + rand(1..168).hours) }
    date_end { date_start + rand(2..12).hours }
    code { SecureRandom.urlsafe_base64(12) }
    time_zone { Faker::Address.time_zone }
    short_url { "#{Faker::Food.fruits}_#{rand(1000)}" }
    uuid { Faker::Internet.uuid }
    specolisto { Constants::TAGS.first.sample }
    international_calendar { rand(0..1) }
    online { false }

    trait :online do
      address { nil }
      city { "Reta" }
      country_id { 999_99 }
      latitude { nil }
      longitude { nil }
      online { true }
    end

    trait :international_calendar do
      international_calendar { true }
    end

    trait :brazila do
      country { Country.find_by(code: "br") }
    end

    trait :usona do
      country { Country.find_by(code: "us") }
      city { "New York" }
      address { "31 Ocean Parkway" }
    end

    trait :japana do
      country { Country.find_by(code: "jp") }
      city { "Tokyo" }
    end

    trait :venonta do
      date_start { Time.zone.today + 1.day }
      date_end { Time.zone.today + 1.day }
    end

    trait :past do
      date_start { Faker::Time.between(from: DateTime.now - 7.days, to: DateTime.now - 2.days) }
    end
  end
end
