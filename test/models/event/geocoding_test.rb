require "test_helper"

class Event::GeocodingTest < ActiveSupport::TestCase
  test "should log error and notify Sentry when geocoding fails" do
    event = build(:event, address: "Failure Street")

    # Simulate Geocoder::RequestDenied being raised by super (Geocoder)
    Geocoder.stub :search, ->(*_args) { raise Geocoder::RequestDenied, "request denied" } do
      # I'll use stubbing with a flag to check calls.
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
    event = build(:event, address: "Network Failure Street")

    Geocoder.stub :search, ->(*_args) { raise SocketError, "getaddrinfo: Name or service not known" } do
      @logger_called = false
      @sentry_called = false

      Rails.logger.stub :error, ->(msg) { @logger_called = true if /getaddrinfo/.match?(msg) } do
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
end
