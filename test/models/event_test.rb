# frozen_string_literal: true

require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @event = create(:evento)
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
    evento            = build(:evento)
    evento.date_start = Time.zone.today
    evento.date_end   = Time.zone.today - 1.day
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

    evento.site  = nil
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

end
