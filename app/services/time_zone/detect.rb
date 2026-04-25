# frozen_string_literal: true

module TimeZone
  # Detects the appropriate IANA time zone for an event during a save cycle.
  #
  # Resolves the time zone from the event's geocoded coordinates when those
  # are present and have changed during the current save. When geocoding
  # produced no coordinates, falls back to the country's default time zone.
  # Reports geocoding exceptions and silent geocoding failures to Sentry so
  # systemic provider issues become visible.
  #
  # The service is a pure detector: it does not mutate the event. The caller
  # applies the returned time zone and status. The payload is a Hash with:
  #
  #   :time_zone [String]            — IANA identifier to assign
  #   :status    [Symbol, nil]       — one of :geocoded, :country_fallback,
  #                                    :failed, or nil when no detection
  #                                    happened on this save
  #
  # @example
  #   result = TimeZone::Detect.call(event: event)
  #   event.time_zone = result.payload[:time_zone]
  #   event.time_zone_detection_status = result.payload[:status]
  #
  class Detect < ApplicationService
    attr_reader :event

    # @param event [Event] the event being saved
    def initialize(event:)
      @event = event
    end

    # @return [ApplicationService::Response]
    def call
      if (event.latitude_changed? || event.longitude_changed?) && event.latitude.present?
        from_coordinates
      elsif event.require_geocode? && event.latitude.nil?
        from_country_after_silent_failure
      else
        success(time_zone: event.time_zone, status: nil)
      end
    end

    private

    # Resolves the time zone from the event's coordinates. Falls back to the
    # country's default zone when the lookup raises (e.g., the +timezone+
    # gem can't classify the coordinates).
    #
    # @return [ApplicationService::Response]
    def from_coordinates
      tz = Timezone.lookup(event.latitude, event.longitude).name
      success(time_zone: tz, status: :geocoded)
    rescue => e
      Sentry.capture_exception(e, extra: {
        event_id: event.id,
        country_id: event.country_id,
        latitude: event.latitude,
        longitude: event.longitude
      })
      country_fallback
    end

    # Reports the silent geocoding failure to Sentry and applies the country
    # fallback. "Silent" because the +geocoder+ gem returns no coordinates
    # without raising when the provider can't resolve the address.
    #
    # @return [ApplicationService::Response]
    def from_country_after_silent_failure
      Sentry.capture_message(
        "Geocoder returned no coordinates for event",
        level: :warning,
        extra: {
          event_id: event.id,
          full_address: event.full_address,
          country_code: event.country&.code
        }
      )
      country_fallback
    end

    # Applies the country's default IANA time zone when geocoding cannot
    # produce one. Marks the detection status as +:country_fallback+ on
    # success or +:failed+ when the country offers no default (e.g., the
    # synthetic "online" country or unknown ISO codes).
    #
    # @return [ApplicationService::Response]
    def country_fallback
      fallback = event.country&.default_time_zone
      if fallback.present?
        success(time_zone: fallback, status: :country_fallback)
      else
        success(time_zone: event.time_zone, status: :failed)
      end
    end
  end
end
