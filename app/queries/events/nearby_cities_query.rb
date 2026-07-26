# frozen_string_literal: true

module Events
  # Finds cities within a fixed radius of a target city.
  #
  # For speed over precision, a city is represented by the coordinates of its
  # first event, and proximity is tested with a rectangular bounding box instead
  # of a precise great-circle distance. All events of a nearby city are treated
  # as equally near (all-or-nothing per city).
  class NearbyCitiesQuery
    # Search radius in kilometers.
    RADIUS_KM = 50

    # Approximate kilometers per degree of latitude.
    KM_PER_DEGREE_LAT = 111.0

    # @param city_name [String] the target city name
    # @param country_id [Integer] the target city's country id
    def initialize(city_name:, country_id:)
      @city_name = city_name
      @country_id = country_id
    end

    # Returns the [city, country_id] pairs of cities within {RADIUS_KM} of the
    # target city, excluding the target city itself and online events.
    #
    # @return [Array<Array(String, Integer)>] nearby [city, country_id] pairs
    def call
      lat, lng = reference_coordinates
      return [] if lat.nil?

      lat_delta = RADIUS_KM / KM_PER_DEGREE_LAT
      lng_delta = RADIUS_KM / (KM_PER_DEGREE_LAT * Math.cos(lat * Math::PI / 180))

      Event.not_online
        .where.not(latitude: nil)
        .where(latitude: (lat - lat_delta)..(lat + lat_delta))
        .where(longitude: (lng - lng_delta)..(lng + lng_delta))
        .where.not(
          "lower(unaccent(events.city)) IN (?, ?) AND events.country_id = ?",
          @city_name.normalized, @city_name.downcase, @country_id
        )
        .distinct
        .pluck(:city, :country_id)
    end

    private

    # Coordinates of the first event in the target city.
    #
    # @return [Array(Float, Float), Array(nil, nil)]
    def reference_coordinates
      Event.by_city(@city_name)
        .by_country_id(@country_id)
        .where.not(latitude: nil)
        .order(:id)
        .pick(:latitude, :longitude)
    end
  end
end
