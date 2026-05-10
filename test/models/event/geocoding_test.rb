# frozen_string_literal: true

require "test_helper"

class Event::GeocodingTest < ActiveSupport::TestCase
  test "should log error and notify Sentry when geocoding fails" do
    # Using build to avoid persistence side effects, but using fixture data
    event = Event.new(events(:valid_event).attributes.merge(address: "Failure Street"))

    # Simulate Geocoder::RequestDenied being raised by super (Geocoder)
    Geocoder.stub :search, ->(*_args) { raise Geocoder::RequestDenied, "request denied" } do
      @logger_called = false
      @sentry_called = false

      Rails.logger.stub :error, ->(msg) { @logger_called = true if msg == "Google API geocoding error for event \"#{event.title}\": request denied" } do
        Sentry.stub :capture_exception, ->(e, extra: {}) {
          @sentry_called = true if e.is_a?(Geocoder::RequestDenied) && extra[:event_title] == event.title
        } do
          event.geocode
          assert @logger_called, "Should have logged error to console with context"
          assert @sentry_called, "Should have notified Sentry with context"
        end
      end
    end
  end

  test "should log error and notify Sentry when a network error occurs" do
    event = Event.new(events(:valid_event).attributes.merge(address: "Network Failure Street"))

    Geocoder.stub :search, ->(*_args) { raise SocketError, "getaddrinfo: Name or service not known" } do
      @logger_called = false
      @sentry_called = false

      Rails.logger.stub :error, ->(msg) { @logger_called = true if msg =~ /getaddrinfo/ } do
        Sentry.stub :capture_exception, ->(e, extra: {}) {
          @sentry_called = true if e.is_a?(SocketError)
        } do
          event.geocode
          assert @logger_called, "Should have logged network error"
          assert @sentry_called, "Should have notified Sentry about network error"
        end
      end
    end
  end

  test "should geocode successfully when API is available" do
    # Ensure geocoder is in test mode (it is in test_helper.rb)
    # Geocoder::Lookup::Test.set_default_stub is already set in test/support/geocoder_stub.rb
    
    event = Event.new(events(:valid_event).attributes.merge(
      address: "New York, NY, USA",
      latitude: nil,
      longitude: nil
    ))
    
    event.geocode
    
    assert_not_nil event.latitude, "Should have geocoded latitude"
    assert_not_nil event.longitude, "Should have geocoded longitude"
    assert_equal 40.71, event.latitude
    assert_equal(-74.00, event.longitude)
  end
end
