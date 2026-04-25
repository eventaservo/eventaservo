# frozen_string_literal: true

require "test_helper"

class TimeZone::DetectTest < ActiveSupport::TestCase
  test "returns :geocoded with the looked-up zone when coordinates are present and changed" do
    event = Event.new(
      country: countries(:country_150),
      city: "Londono",
      address: "10 Downing Street",
      latitude: 51.5074,
      longitude: -0.1278
    )

    # Stub the timezone gem inline so the test does not depend on the
    # backend the +timezone+ gem is configured with at boot.
    lookup_double = Struct.new(:name).new("Europe/London")
    result = nil
    Timezone.stub(:lookup, ->(_lat, _lng) { lookup_double }) do
      result = TimeZone::Detect.call(event: event)
    end

    assert result.success?
    assert_equal "Europe/London", result.payload[:time_zone]
    assert_equal :geocoded, result.payload[:status]
  end

  test "returns :country_fallback when geocoding produced no coordinates and country has a default" do
    event = Event.new(
      country: countries(:country_150),
      city: "Groningen",
      address: "Arubastraat 12",
      latitude: nil,
      longitude: nil
    )
    expected_tz = TZInfo::Country.get("NL").zone_identifiers.first

    result = nil
    Sentry.stub(:capture_message, ->(*) {}) do
      result = TimeZone::Detect.call(event: event)
    end

    assert result.success?
    assert_equal expected_tz, result.payload[:time_zone]
    assert_equal :country_fallback, result.payload[:status]
  end

  test "reports a Sentry warning when geocoding produced no coordinates" do
    event = Event.new(
      country: countries(:country_150),
      city: "Groningen",
      address: "Arubastraat 12",
      latitude: nil,
      longitude: nil
    )

    captured = []
    Sentry.stub(:capture_message, ->(msg, **opts) { captured << [msg, opts] }) do
      TimeZone::Detect.call(event: event)
    end

    assert_equal 1, captured.size
    assert_match(/no coordinates/i, captured.first.first)
    assert_equal :warning, captured.first.last[:level]
  end

  test "returns :failed when geocoding produced no coordinates and country has no default" do
    fake_country = Country.new(name: "Sennoma", continent: "Eŭropo", code: "zz")
    event = Event.new(
      country: fake_country,
      city: "Iuloko",
      address: "Sennoma strato 1",
      latitude: nil,
      longitude: nil
    )

    result = nil
    Sentry.stub(:capture_message, ->(*) {}) do
      result = TimeZone::Detect.call(event: event)
    end

    assert result.success?
    assert_equal :failed, result.payload[:status]
  end

  test "returns nil status when nothing relevant changed" do
    event = events(:valid_event)
    # No dirty attributes; latitude unchanged.
    result = TimeZone::Detect.call(event: event)

    assert result.success?
    assert_nil result.payload[:status]
    assert_equal event.time_zone, result.payload[:time_zone]
  end

  test "returns nil status for universal online events" do
    event = Event.new(
      country: countries(:country_99999),
      city: "Reta",
      online: true,
      latitude: nil,
      longitude: nil
    )

    result = TimeZone::Detect.call(event: event)

    assert result.success?
    assert_nil result.payload[:status]
  end

  test "falls back to country default and reports Sentry exception when Timezone.lookup raises" do
    event = Event.new(
      country: countries(:country_150),
      city: "Amsterdamo",
      address: "Damrak 1",
      latitude: 1.0,
      longitude: 2.0
    )
    expected_tz = TZInfo::Country.get("NL").zone_identifiers.first

    captured_exceptions = []
    Timezone.stub(:lookup, ->(_lat, _lng) { raise "boom" }) do
      Sentry.stub(:capture_exception, ->(e, **opts) { captured_exceptions << [e, opts] }) do
        result = TimeZone::Detect.call(event: event)

        assert result.success?
        assert_equal expected_tz, result.payload[:time_zone]
        assert_equal :country_fallback, result.payload[:status]
      end
    end

    assert_equal 1, captured_exceptions.size
    assert_equal "boom", captured_exceptions.first.first.message
  end
end
