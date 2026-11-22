# frozen_string_literal: true

require "test_helper"

class Event::TimezoneUpdateTest < ActiveSupport::TestCase
  # Success cases

  test "updates timezone when address changes even if geocoded coordinates remain identical" do
    event = events(:valid_event)
    event.update_columns(latitude: 40.71, longitude: -74.00, time_zone: "Etc/UTC")

    event.update!(address: "100 Broadway")

    assert_equal 40.71, event.latitude
    assert_equal(-74.00, event.longitude)
    assert_equal "America/New_York", event.time_zone
  end

  test "updates timezone only once per save when address changes and geocoding succeeds" do
    event = events(:valid_event)
    event.update_columns(latitude: nil, longitude: nil, time_zone: "Etc/UTC")

    lookup_calls = 0
    fake_zone = Struct.new(:name).new("America/New_York")

    lookup_stub = lambda do |_lat, _lon|
      lookup_calls += 1
      fake_zone
    end

    Timezone.stub :lookup, lookup_stub do
      event.update!(address: "200 Park Ave")
    end

    assert_equal 1, lookup_calls
    assert_equal "America/New_York", event.time_zone
  end

  test "updates timezone when coordinates are updated directly without address change" do
    event = events(:valid_event)
    event.update_columns(latitude: 40.71, longitude: -74.00, time_zone: "America/New_York")

    event.update!(latitude: 48.8566, longitude: 2.3522)

    assert_equal "Europe/Paris", event.time_zone
  end

  # Edge cases

  test "preserves existing timezone when geocoding raises an error" do
    event = events(:valid_event)
    event.update_columns(latitude: 40.71, longitude: -74.00, time_zone: "America/New_York")

    Geocoder.stub :search, ->(*_args) { raise Geocoder::RequestDenied, "request denied" } do
      Rails.logger.stub :error, ->(_msg) {} do
        Sentry.stub :capture_exception, ->(*_args, **_kwargs) {} do
          event.update!(address: "Failing Address")
        end
      end
    end

    assert_equal "America/New_York", event.time_zone
  end

  test "preserves user timezone when event becomes purely online" do
    event = events(:valid_event)
    event.update_columns(latitude: 40.71, longitude: -74.00, time_zone: "Europe/Paris")

    event.update!(online: true, city: "Reta", country_id: 99_999)

    assert_nil event.latitude
    assert_nil event.longitude
    assert_equal "Europe/Paris", event.time_zone
  end
end
