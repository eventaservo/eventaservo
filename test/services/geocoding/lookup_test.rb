# frozen_string_literal: true

require "test_helper"

class Geocoding::LookupTest < ActiveSupport::TestCase
  # Success cases

  test "returns coordinates when geocoder finds a match" do
    result = Geocoding::Lookup.call(query: "New York, NY, USA")

    assert result.success?
    assert_in_delta 40.71, result.payload.latitude
    assert_in_delta(-74.00, result.payload.longitude)
  end

  # Error cases

  test "fails when address query is blank" do
    result = Geocoding::Lookup.call(query: "")

    assert result.failure?
    assert_equal "Address query is blank", result.error
  end

  test "fails when geocoder returns no results" do
    Geocoder.stub :search, ->(*_args) { [] } do
      result = Geocoding::Lookup.call(query: "Nowhere")

      assert result.failure?
      assert_equal "No geocoding results found", result.error
    end
  end

  test "logs error and notifies Sentry when geocoding raises Geocoder::Error" do
    logger_called = false
    sentry_extra = nil

    Geocoder.stub :search, ->(*_args) { raise Geocoder::RequestDenied, "request denied" } do
      Rails.logger.stub :error, ->(msg) { logger_called = true if msg == "Google API geocoding error for event \"Kongreso\": request denied" } do
        Sentry.stub :capture_exception, ->(err, extra: {}) { sentry_extra = extra if err.is_a?(Geocoder::RequestDenied) } do
          result = Geocoding::Lookup.call(query: "Failure Street", context: {event_id: 1, event_title: "Kongreso"})

          assert result.failure?
          assert_equal "request denied", result.error
          assert logger_called
          assert_equal "Kongreso", sentry_extra[:event_title]
        end
      end
    end
  end

  test "logs error and notifies Sentry when a network error occurs" do
    logger_called = false
    sentry_called = false

    Geocoder.stub :search, ->(*_args) { raise SocketError, "getaddrinfo: Name or service not known" } do
      Rails.logger.stub :error, ->(msg) { logger_called = true if msg.include?("getaddrinfo") } do
        Sentry.stub :capture_exception, ->(err, extra: {}) { sentry_called = true if err.is_a?(SocketError) } do
          result = Geocoding::Lookup.call(query: "Network Failure Street", context: {event_title: "Kongreso"})

          assert result.failure?
          assert logger_called
          assert sentry_called
        end
      end
    end
  end
end
