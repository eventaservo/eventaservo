# frozen_string_literal: true

module Geocoding
  # Looks up geographic coordinates (latitude and longitude) for an address query.
  #
  # Wraps +Geocoder.search+, rescues provider and network errors, logs failures
  # to Rails logs and Sentry, and returns a structured {ApplicationService::Response}.
  #
  # @example Resolve coordinates for an address
  #   result = Geocoding::Lookup.call(query: "New York, NY, USA")
  #   result.success?          # => true
  #   result.payload.latitude  # => 40.71
  #   result.payload.longitude # => -74.00
  class Lookup < ApplicationService
    # Value object representing resolved geographic coordinates.
    Coordinates = Data.define(:latitude, :longitude)

    attr_reader :query, :context

    # @param query [String, nil] full address string to geocode
    # @param context [Hash] optional metadata included in error logs and Sentry reports
    def initialize(query:, context: {})
      @query = query
      @context = context
    end

    # Queries the configured geocoding provider for coordinates.
    #
    # @return [ApplicationService::Response] success with {Coordinates} payload,
    #   or failure with error message
    def call
      return failure("Address query is blank") if query.blank?

      match = Geocoder.search(query).first
      if match&.latitude.nil? || match&.longitude.nil?
        return failure("No geocoding results found")
      end

      success(Coordinates.new(latitude: match.latitude, longitude: match.longitude))
    rescue Geocoder::Error, SocketError, Timeout::Error => e
      handle_lookup_error(e)
    end

    private

    # Logs and reports a geocoding failure to Rails logs and Sentry.
    #
    # @param error [StandardError] the rescued geocoding or network exception
    #
    # @return [ApplicationService::Response]
    def handle_lookup_error(error)
      label = context[:event_title].present? ? " for event \"#{context[:event_title]}\"" : ""
      Rails.logger.error "Google API geocoding error#{label}: #{error.message}"
      Sentry.capture_exception(error, extra: context)
      failure(error.message)
    end
  end
end
