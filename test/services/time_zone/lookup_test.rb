# frozen_string_literal: true

require "test_helper"

class TimeZone::LookupTest < ActiveSupport::TestCase
  # Success cases

  test "returns canonical timezone name for valid coordinates" do
    result = TimeZone::Lookup.call(latitude: 40.71, longitude: -74.00)

    assert result.success?
    assert_equal "America/New_York", result.payload
  end

  test "normalizes legacy timezone identifiers returned by lookup provider" do
    fake_zone = Struct.new(:name).new("Asia/Saigon")

    Timezone.stub :lookup, ->(_lat, _lon) { fake_zone } do
      result = TimeZone::Lookup.call(latitude: 10.82, longitude: 106.63)

      assert result.success?
      assert_equal "Asia/Ho_Chi_Minh", result.payload
    end
  end

  # Error cases

  test "fails with UTC fallback when provider returns an unrecognized timezone name" do
    fake_zone = Struct.new(:name).new("Invalid/Zone")

    Timezone.stub :lookup, ->(_lat, _lon) { fake_zone } do
      result = TimeZone::Lookup.call(latitude: 40.71, longitude: -74.00)

      assert result.failure?
      assert_equal "Etc/UTC", result.payload
      assert_includes result.error, "Invalid/Zone"
    end
  end

  test "fails with UTC fallback when coordinates are missing" do
    result = TimeZone::Lookup.call(latitude: nil, longitude: -74.00)

    assert result.failure?
    assert_equal "Etc/UTC", result.payload
  end

  test "logs error, notifies Sentry, and returns UTC fallback when provider raises" do
    logger_called = false
    sentry_extra = nil

    Timezone.stub :lookup, ->(_lat, _lon) { raise StandardError, "quota exceeded" } do
      Rails.logger.stub :error, ->(msg) { logger_called = true if msg.include?("quota exceeded") && msg.include?("Test Event") } do
        Sentry.stub :capture_exception, ->(err, extra: {}) {
          sentry_extra = extra if err.message == "quota exceeded"
        } do
          result = TimeZone::Lookup.call(
            latitude: 40.71,
            longitude: -74.00,
            context: {event_id: 1, event_title: "Test Event"}
          )

          assert result.failure?
          assert_equal "Etc/UTC", result.payload
          assert_equal "quota exceeded", result.error
          assert logger_called
          assert_equal "Test Event", sentry_extra[:event_title]
          assert_in_delta 40.71, sentry_extra[:lat]
        end
      end
    end
  end
end
