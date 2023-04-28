# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                     :bigint           not null, primary key
#  address                :string
#  cancel_reason          :text
#  cancelled              :boolean          default(FALSE)
#  city                   :text
#  code                   :string           not null
#  content                :text
#  date_end               :datetime
#  date_start             :datetime         not null
#  deleted                :boolean          default(FALSE), not null
#  description            :string(400)
#  display_flag           :boolean          default(TRUE)
#  email                  :string
#  import_url             :string(400)
#  international_calendar :boolean          default(FALSE)
#  latitude               :float
#  longitude              :float
#  metadata               :jsonb
#  online                 :boolean          default(FALSE)
#  participants_count     :integer          default(0)
#  short_url              :string
#  site                   :string
#  specolisto             :string           default("Kunveno")
#  time_zone              :string           default("Etc/UTC"), not null
#  title                  :string           not null
#  uuid                   :uuid
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  country_id             :integer          not null
#  region_id              :integer
#  user_id                :integer          not null
#
# Indexes
#
#  index_events_on_address             (address)
#  index_events_on_cancelled           (cancelled)
#  index_events_on_city                (city)
#  index_events_on_content             (md5(content))
#  index_events_on_date_end            (date_end)
#  index_events_on_date_start          (date_start)
#  index_events_on_deleted             (deleted)
#  index_events_on_description         (description)
#  index_events_on_online              (online)
#  index_events_on_participants_count  (participants_count)
#  index_events_on_specolisto          (specolisto)
#  index_events_on_title               (title)
#  index_events_on_user_id             (user_id)
#
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
    date_start { Time.zone.now + rand(0..168).hours }
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
      date_start { Time.zone.now + rand(0..2).days }
      date_end { date_start + rand(2..36).hours }
    end

    trait :past do
      date_start { Faker::Time.between(from: DateTime.now - 7.days, to: DateTime.now - 2.days) }
    end
  end
end
