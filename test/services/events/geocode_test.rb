# frozen_string_literal: true

require "test_helper"

class Events::GeocodeTest < ActiveSupport::TestCase
  # Success cases

  test "geocodes new event and assigns coordinates and timezone" do
    event = Event.new(events(:valid_event).attributes.except("id").merge(
      address: "New York, NY, USA",
      latitude: nil,
      longitude: nil,
      time_zone: "Etc/UTC"
    ))

    result = Events::Geocode.call(event:)

    assert result.success?
    assert_in_delta 40.71, event.latitude
    assert_in_delta(-74.00, event.longitude)
    assert_equal "America/New_York", event.time_zone
  end

  test "refreshes timezone when address changes even if geocoded coordinates remain identical" do
    event = events(:valid_event)
    event.update_columns(latitude: 40.71, longitude: -74.00, time_zone: "Etc/UTC")
    event.address = "100 Broadway"

    result = Events::Geocode.call(event:)

    assert result.success?
    assert_in_delta 40.71, event.latitude
    assert_in_delta(-74.00, event.longitude)
    assert_equal "America/New_York", event.time_zone
  end

  test "skips geocoding when persisted event has no location changes" do
    event = events(:valid_event)
    event.update_columns(latitude: 40.71, longitude: -74.00, time_zone: "Europe/Paris")
    event.title = "Renamed Event"

    geocode_called = false
    Geocoder.stub :search, ->(*_args) { geocode_called = true } do
      result = Events::Geocode.call(event:)

      assert result.success?
      assert_not geocode_called
      assert_equal "Europe/Paris", event.time_zone
    end
  end

  test "geocodes persisted event without location changes when force is true" do
    event = events(:valid_event)
    event.update_columns(latitude: 40.71, longitude: -74.00, time_zone: "Etc/UTC")

    result = Events::Geocode.call(event:, force: true)

    assert result.success?
    assert_equal "America/New_York", event.time_zone
  end

  test "refreshes timezone when coordinates change directly without address changes" do
    event = events(:valid_event)
    event.update_columns(latitude: 40.71, longitude: -74.00, time_zone: "America/New_York")
    event.assign_attributes(latitude: 48.8566, longitude: 2.3522)

    geocode_called = false
    Geocoder.stub :search, ->(*_args) { geocode_called = true } do
      result = Events::Geocode.call(event:)

      assert result.success?
      assert_not geocode_called
      assert_equal "Europe/Paris", event.time_zone
    end
  end

  test "skips geocoding for purely online events and preserves user timezone" do
    event = events(:valid_event)
    event.assign_attributes(online: true, city: "Reta", country_id: 99_999, time_zone: "Europe/Paris")

    geocode_called = false
    Geocoder.stub :search, ->(*_args) { geocode_called = true } do
      result = Events::Geocode.call(event:)

      assert result.success?
      assert_not geocode_called
      assert_equal "Europe/Paris", event.time_zone
    end
  end

  # Error cases

  test "preserves existing coordinates and timezone when geocoding fails" do
    event = events(:valid_event)
    event.update_columns(latitude: 48.8566, longitude: 2.3522, time_zone: "Europe/Paris")
    event.address = "Failing Address"

    Geocoder.stub :search, ->(*_args) { raise Geocoder::RequestDenied, "request denied" } do
      Rails.logger.stub :error, ->(_msg) {} do
        Sentry.stub :capture_exception, ->(*_args, **_kwargs) {} do
          result = Events::Geocode.call(event:)

          assert result.failure?
          assert_in_delta 48.8566, event.latitude
          assert_in_delta 2.3522, event.longitude
          assert_equal "Europe/Paris", event.time_zone
        end
      end
    end
  end
end
