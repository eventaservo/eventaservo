# frozen_string_literal: true

module Events
  # Finds cities within a fixed radius of a target city.
  #
  # For speed over precision, a city is represented by the coordinates of its
  # first event (its reference point), and all events of a nearby city are
  # treated as equally near (all-or-nothing per city).
  #
  # Proximity is decided in two steps: a cheap rectangular bounding box (backed
  # by the index on +[latitude, longitude]+) narrows the candidate cities, then
  # a precise Haversine great-circle distance between the two cities' reference
  # points removes the corner false positives the box lets through. Because the
  # box circumscribes the radius circle, no truly-nearby city is ever missed.
  class NearbyCitiesQuery
    # Search radius in kilometers.
    RADIUS_KM = 50

    # Approximate kilometers per degree of latitude.
    KM_PER_DEGREE_LAT = 111.0

    # How long a computed nearby-cities list stays cached. The relationship
    # only changes when events appear/disappear near the city, so a stale entry
    # is harmless for a few hours.
    CACHE_TTL = 12.hours

    # @param city_name [String] the target city name
    # @param country_id [Integer] the target city's country id
    def initialize(city_name:, country_id:)
      @city_name = city_name
      @country_id = country_id
    end

    # Returns the [city, country_id] pairs of cities within {RADIUS_KM} of the
    # target city, excluding the target city itself and online events.
    #
    # The result is cached per (country_id, normalized city) since it is stable
    # and recomputed on every city-page request.
    #
    # @return [Array<Array(String, Integer)>] nearby [city, country_id] pairs
    def call
      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) { compute }
    end

    private

    # @return [String] the cache key for this city
    def cache_key
      "events/nearby_cities/#{@country_id}/#{@city_name.normalized}"
    end

    # Computes the nearby [city, country_id] pairs without caching.
    #
    # @return [Array<Array(String, Integer)>]
    def compute
      origin = reference_coordinates
      return [] if origin.nil?

      candidate_reference_points(origin).filter_map do |city, country_id, lat, lng|
        distance = Geocoder::Calculations.distance_between(origin, [lat, lng], units: :km)
        [city, country_id] if distance <= RADIUS_KM
      end
    end

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

    # Candidate cities (other than the target) with the coordinates of each
    # city's first event as its reference point.
    #
    # @param origin [Array(Float, Float)] the target city's reference point
    # @return [Array<Array(String, Integer, Float, Float)>] [city, country_id, lat, lng]
    def candidate_reference_points(origin)
      pairs = bounding_box_city_pairs(origin)
      return [] if pairs.empty?

      first_event_coordinates_for(pairs)
    end

    # Distinct [city, country_id] pairs having at least one event inside the
    # bounding box around +origin+ (excluding the target city and online events).
    #
    # @param origin [Array(Float, Float)] the target city's reference point
    # @return [Array<Array(String, Integer)>]
    def bounding_box_city_pairs(origin)
      lat, lng = origin
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

    # First event (lowest id) of each given [city, country_id] pair with its
    # coordinates. Computed over all of the city's events — not only those in
    # the bounding box — so the reference point is stable and symmetric.
    #
    # @param pairs [Array<Array(String, Integer)>] candidate [city, country_id] pairs
    # @return [Array<Array(String, Integer, Float, Float)>] [city, country_id, lat, lng]
    def first_event_coordinates_for(pairs)
      clause = pairs.map { "(events.city = ? AND events.country_id = ?)" }.join(" OR ")
      binds = pairs.flat_map { |city, country_id| [city, country_id] }

      Event.where.not(latitude: nil)
        .where(clause, *binds)
        .select("DISTINCT ON (events.city, events.country_id) events.city, events.country_id, events.latitude, events.longitude")
        .order("events.city, events.country_id, events.id")
        .map { |e| [e.city, e.country_id, e.latitude, e.longitude] }
    end
  end
end
