# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                     :bigint           not null, primary key
#  address                :string           indexed
#  cancel_reason          :text
#  cancelled              :boolean          default(FALSE), indexed
#  city                   :text             indexed
#  code                   :string           not null
#  content                :text
#  date_end               :datetime         indexed
#  date_start             :datetime         not null, indexed, indexed => [is_recurring_master], indexed => [master_event_id]
#  deleted                :boolean          default(FALSE), not null, indexed
#  description            :string(400)      indexed
#  display_flag           :boolean          default(TRUE)
#  email                  :string
#  format                 :string           indexed
#  import_url             :string(400)
#  international_calendar :boolean          default(FALSE)
#  is_recurring_master    :boolean          default(FALSE), not null, indexed, indexed => [date_start]
#  latitude               :float
#  longitude              :float
#  metadata               :jsonb
#  online                 :boolean          default(FALSE), indexed
#  participants_count     :integer          default(0), indexed
#  short_url              :string
#  site                   :string
#  specolisto             :string           default("Kunveno"), indexed
#  time_zone              :string           default("Etc/UTC"), not null
#  title                  :string           not null, indexed
#  uuid                   :uuid
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  country_id             :integer          not null
#  master_event_id        :bigint           indexed, indexed => [date_start]
#  user_id                :integer          not null, indexed
#
# Foreign Keys
#
#  fk_rails_...  (master_event_id => events.id)
#
FactoryBot.define do
  factory :event, aliases: [:evento], class: :event do
    after(:build) do |event|
      event.instance_variable_set(:@created_from_factory, true)
    end
    after(:create) do |event|
      event.tags << Tag.categories.first
    end

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
    date_start { Time.zone.today + rand(8..12).hours }
    date_end { date_start + rand(13..20).hours }
    code { SecureRandom.urlsafe_base64(12) }
    time_zone { Faker::Address.time_zone }
    short_url { "#{Faker::Lorem.word}_#{rand(1000)}" }
    uuid { Faker::Internet.uuid }
    specolisto { Constants::TAGS.first.sample }
    international_calendar { rand(0..1) }
    online { false }
    format { "onsite" }

    trait :online do
      address { nil }
      city { "Reta" }
      country_id { 999_99 }
      latitude { nil }
      longitude { nil }
      online { true }
      format { "online" }
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

    trait :future do
      date_start { Time.zone.now + rand(0..90).days }
      date_end { date_start + rand(2..36).hours }
    end

    trait :past do
      date_start { Faker::Time.between(from: DateTime.now - 90.days, to: DateTime.now - 2.days) }
    end

    trait :recurring_parent do
      is_recurring_master { true }
      after(:create) do |event|
        create(:event_recurrence, master_event: event)
      end
    end
  end
end
