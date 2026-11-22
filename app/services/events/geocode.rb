# frozen_string_literal: true

module Events
  # Resolves geographic coordinates and timezone for an {Event} in memory.
  #
  # Coordinates {Geocoding::Lookup} and {TimeZone::Lookup} whenever an event's
  # location is new or changed (or when +force: true+ is passed). Always refreshes
  # the timezone after successful geocoding — even when the resolved coordinates
  # match the previous values — and skips purely online (+universala?+) events.
  #
  # @example Geocode a new or modified event before saving
  #   Events::Geocode.call(event: event)
  class Geocode < ApplicationService
    attr_reader :event, :force

    # @param event [Event] the event whose coordinates and timezone should be resolved
    # @param force [Boolean] when true, geocode even if address fields have not changed
    def initialize(event:, force: false)
      @event = event
      @force = force
    end

    # Resolves and assigns +latitude+, +longitude+, and +time_zone+ on +event+.
    #
    # @return [ApplicationService::Response] success with Event payload (including no-op skips),
    #   or failure with error message if geocoding fails
    def call
      return success(event) unless should_geocode?

      geo_result = Geocoding::Lookup.call(query: event.full_address, context: log_context)
      return failure(geo_result.error, payload: event) if geo_result.failure?

      assign_coordinates_and_timezone(geo_result.payload)
      success(event)
    end

    private

    # Checks whether geocoding should run for the current event state.
    #
    # @return [Boolean]
    def should_geocode?
      return false if event.universala?
      return false if event.full_address.blank?

      force || event.new_record? || location_changed?
    end

    # Checks whether any address component affecting geocoding has changed.
    #
    # @return [Boolean]
    def location_changed?
      event.address_changed? || event.city_changed? || event.country_id_changed?
    end

    # Assigns resolved coordinates and refreshes +time_zone+ via {TimeZone::Lookup}.
    #
    # @param coordinates [Geocoding::Lookup::Coordinates] resolved latitude and longitude
    #
    # @return [void]
    def assign_coordinates_and_timezone(coordinates)
      event.latitude = coordinates.latitude
      event.longitude = coordinates.longitude

      tz_result = TimeZone::Lookup.call(
        latitude: event.latitude,
        longitude: event.longitude,
        context: log_context
      )
      event.time_zone = tz_result.success? ? tz_result.payload : TimeZone::Lookup::DEFAULT_TIME_ZONE
    end

    # Builds context metadata for geocoding and timezone error reports.
    #
    # @return [Hash{Symbol => Object}]
    def log_context
      {event_id: event.id || "new record", event_title: event.title}
    end
  end
end
