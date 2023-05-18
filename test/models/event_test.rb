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
require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @event = FactoryBot.create(:event)
    @user = FactoryBot.create(:user)
  end

  test "evento havas administranto" do
    assert_not_nil Event.reflect_on_association(:user)
  end

  test "evento havas landon" do
    assert_not_nil Event.reflect_on_association(:country)
  end

  test "titolo necesas" do
    evento = build(:evento, title: nil)
    assert evento.invalid?
  end

  test "title is limited to 100 characters" do
    event = build(:event, title: Faker::Lorem.paragraph_by_chars(number: 100))
    assert event.valid?

    event.title = Faker::Lorem.paragraph_by_chars(number: 101)
    refute event.valid?
  end

  test "priskribo necesas" do
    evento = build(:evento, description: nil)
    assert evento.invalid?
  end

  test "urbo necesas" do
    evento = build(:evento, city: nil)
    assert evento.invalid?
  end

  test "evento sen lando devas fiaski" do
    evento = build(:evento, country_id: nil)
    assert evento.invalid?
  end

  test "komenca dato necesas" do
    evento = build(:event, date_start: nil, date_end: nil)
    assert evento.invalid?
  end

  test "fina dato necesas" do
    evento = build(:evento, date_end: nil)
    assert evento.invalid?
  end

  test "kodo necesas" do
    evento = build(:evento, code: nil)
    assert evento.invalid?
  end

  test "fina dato devas esti post komenca dato" do
    evento = build(:evento)
    evento.date_start = Time.zone.today
    evento.date_end = Time.zone.today - 1.day
    assert_not evento.save
  end

  test "forigas kaj malforigas la eventon, sed ne el la datumbazo" do
    @event.delete!
    assert_equal @event.deleted, true

    @event.undelete!
    assert_equal @event.deleted, false
  end

  test "serĉado" do
    evento = create(:evento, :brazila)
    assert Event.search("brazilo").exists?(id: evento.id)
  end

  test "priskribo ne povas esti pli ol 400 signoj" do
    @event.description = SecureRandom.hex(201) # Pli ol 400 signoj
    assert @event.invalid?
  end

  test "retejo devas enhavi http se ankoraŭ ne havas ĝin" do
    @event.update!(site: "google.com")
    assert_equal "http://google.com", @event.site
  end

  test "ne aldonu http se retejo jam havas ĝin" do
    @event.update!(site: "https://google.com")
    assert_equal "https://google.com", @event.site
  end

  test "ne aldonu http se ne estas retejo" do
    @event.update!(site: nil)
    assert_nil @event.site

    @event.update!(site: "")
    assert_nil @event.site

    @event.update!(site: " ")
    assert_nil @event.site

    @event.update!(site: "google.com")
    assert_equal "http://google.com", @event.site
  end

  test "forigas malpermesatajn signojn el urbonomo" do
    @event.update!(city: "urbo / alia urbo")
    assert_equal "urbo  alia urbo", @event.city
  end

  test "geocoder, dum provoj, devas informi la NY adreson" do
    event = create(:evento, :usona)
    event.geocode
    event.save!
    assert_equal 40.71, event.latitude
    assert_equal(-74.00, event.longitude)
  end

  test "endas plenumi retadreson au retposhtadreson" do
    evento = build_stubbed(:evento)
    assert evento.valid?

    evento.site = nil
    evento.email = nil
    assert evento.invalid?

    evento.site = Faker::Internet.url
    assert evento.valid?

    evento.site = nil
    evento.email = Faker::Internet.email
    assert evento.valid?
  end

  test ".cet?" do
    london_event = build(:evento, time_zone: "Europe/London")
    assert_not london_event.cet?

    paris_event = build(:evento, time_zone: "Europe/Paris")
    assert paris_event.cet?
  end

  test ".komenca_dato" do
    date_start = Time.parse("2023-02-13 15:00 UTC")

    event = FactoryBot.build(:evento, date_start: date_start, date_end: date_start + 1.hour)
    assert_equal date_start.in_time_zone("UTC"), event.komenca_dato
    assert_equal date_start.in_time_zone("America/Recife"), event.komenca_dato(horzono: "America/Recife")
  end

  test ".fina_dato" do
    date_end = Time.parse("2023-02-13 16:00 UTC")

    event = FactoryBot.build(:evento, date_start: date_end - 1.hour, date_end: date_end)
    assert_equal date_end.in_time_zone("UTC"), event.fina_dato
    assert_equal date_end.in_time_zone("America/Recife"), event.fina_dato(horzono: "America/Recife")
  end

  test ".add_participant" do
    assert_difference "@event.participants.count", 1 do
      @event.add_participant(@user)
    end
  end

  test ".remove_participant" do
    @event.add_participant(@user)

    assert_difference "@event.participants.count", -1 do
      @event.remove_participant(@user)
    end
  end

  test "normalize title" do
    event1 = FactoryBot.create(:event, title: "UEA Universala Kongreso")
    assert_equal "UEA Universala Kongreso", event1.title

    event2 = FactoryBot.create(:event, title: "UEA UNIVERSALA KONGRESO  ")
    assert_equal "Uea Universala Kongreso", event2.title
  end

  test "#past?" do
    past_event = FactoryBot.build(:event, date_start: 1.day.ago, date_end: 1.day.ago)
    assert past_event.past?

    past_event.update(date_end: Time.zone.today)
    assert_not past_event.past?
  end
end
