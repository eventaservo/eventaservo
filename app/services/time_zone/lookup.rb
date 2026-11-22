# frozen_string_literal: true

module TimeZone
  # Looks up and normalizes an IANA timezone identifier from geographic coordinates.
  #
  # Wraps the +timezone+ gem lookup, normalizes the resolved identifier via
  # {TimeZone::Normalize}, and reports lookup failures to Rails logs and Sentry
  # while returning +"Etc/UTC"+ as a fallback payload.
  #
  # @example Look up timezone from coordinates
  #   result = TimeZone::Lookup.call(latitude: 40.71, longitude: -74.00)
  #   result.success? # => true
  #   result.payload  # => "America/New_York"
  class Lookup < ApplicationService
    DEFAULT_TIME_ZONE = "Etc/UTC"

    attr_reader :latitude, :longitude, :context

    # @param latitude [Float, nil] latitude coordinate
    # @param longitude [Float, nil] longitude coordinate
    # @param context [Hash] optional context metadata for error logs and Sentry
    def initialize(latitude:, longitude:, context: {})
      @latitude = latitude
      @longitude = longitude
      @context = context
    end

    # Resolves the canonical IANA timezone name for the given coordinates.
    #
    # @return [ApplicationService::Response] success with canonical timezone string,
    #   or failure with error message and +"Etc/UTC"+ fallback payload
    def call
      return failure("Coordinates are required", payload: DEFAULT_TIME_ZONE) if latitude.nil? || longitude.nil?

      raw_name = ::Timezone.lookup(latitude, longitude).name
      normalized = TimeZone::Normalize.call(raw_name)
      success(normalized.success? ? normalized.payload : DEFAULT_TIME_ZONE)
    rescue => e
      log_error(e)
      Sentry.capture_exception(e, extra: context.merge(lat: latitude, lon: longitude))
      failure(e.message, payload: DEFAULT_TIME_ZONE)
    end

    private

    # Writes a structured error message to the Rails logger.
    #
    # @param error [StandardError] the rescued lookup exception
    #
    # @return [void]
    def log_error(error)
      label = context[:event_title].present? ? " for event \"#{context[:event_title]}\"" : ""
      Rails.logger.error "Timezone lookup error#{label} (#{latitude}, #{longitude}): #{error.message}"
    end
  end
end
