# frozen_string_literal: true

module Events
  # Finds neighboring cities within a given radius of a target city.
  #
  # Employs a two-stage spatial search with caching for high performance:
  # 1. An indexed bounding-box query in SQL narrows candidate cities, with full
  #    handling for antimeridian crossing (±180° longitude).
  # 2. A precise great-circle Haversine calculation eliminates false-positive
  #    corner points exceeding the specified radius.
  #
  # A city is anchored by the coordinates of its first event with valid coordinates.
  # Results are cached in {Rails.cache} for 12 hours.
  #
  # @example Query nearby cities with the default 120 km radius
  #   Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: 41).call
  #   # => [["Malmö", 212], ["Roskilde", 41]]
  #
  # @example Query with a custom radius
  #   Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: 41, radius_km: 50).call
  #
  class NearbyCitiesQuery
    # Default search radius in kilometers.
    DEFAULT_RADIUS_KM = 120

    # Approximate kilometers per degree of latitude.
    KM_PER_DEGREE_LAT = 111.0

    # How long computed nearby cities remain cached.
    CACHE_TTL = 12.hours

    attr_reader :city_name, :country_id, :radius_km

    # @param city_name [String] The target city name
    # @param country_id [Integer] The target city country ID
    # @param radius_km [Numeric] The discovery radius in kilometers (defaults to 120 km)
    def initialize(city_name:, country_id:, radius_km: DEFAULT_RADIUS_KM)
      @city_name = city_name
      @country_id = country_id
      @radius_km = radius_km
    end

    # Returns [city, country_id] pairs of cities within {radius_km} of the target city.
    #
    # Excludes the target city itself and online events. Returns cached results when available.
    #
    # @return [Array<Array(String, Integer)>] Array of [city, country_id] pairs
    def call
      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) { compute }
    end

    private

    # Cache key identifying this city query and radius.
    #
    # @return [String]
    def cache_key
      "events/nearby_cities/v2/#{country_id}/#{city_name.normalized}/#{radius_km}"
    end

    # Executes the two-stage search without cache.
    #
    # @return [Array<Array(String, Integer)>]
    def compute
      origin = reference_coordinates
      return [] if origin.nil?

      candidate_reference_points(origin).filter_map do |city, candidate_country_id, lat, lng|
        distance = Geocoder::Calculations.distance_between(origin, [lat, lng], units: :km)
        [city, candidate_country_id] if distance <= radius_km
      end
    end

    # Coordinates of the first event in the target city.
    #
    # @return [Array(Float, Float), nil] [latitude, longitude] or nil if no coordinates exist
    def reference_coordinates
      Event.by_city(city_name)
        .by_country_id(country_id)
        .where.not(latitude: nil)
        .where.not(longitude: nil)
        .order(:id)
        .pick(:latitude, :longitude)
    end

    # Candidate cities with coordinates of each city's first event as its reference point.
    #
    # @param origin [Array(Float, Float)] The target city's reference coordinates
    #
    # @return [Array<Array(String, Integer, Float, Float)>] [city, country_id, latitude, longitude]
    def candidate_reference_points(origin)
      pairs = bounding_box_city_pairs(origin)
      return [] if pairs.empty?

      first_event_coordinates_for(pairs)
    end

    # Candidate [city, country_id] pairs within the bounding box around +origin+.
    #
    # Handles antimeridian wrapping if the longitude delta crosses ±180°.
    #
    # @param origin [Array(Float, Float)]
    #
    # @return [Array<Array(String, Integer)>]
    def bounding_box_city_pairs(origin)
      lat, lng = origin
      lat_delta = radius_km.to_f / KM_PER_DEGREE_LAT
      cos_lat = Math.cos(lat * Math::PI / 180.0).abs
      cos_lat = 0.0001 if cos_lat < 0.0001
      lng_delta = radius_km.to_f / (KM_PER_DEGREE_LAT * cos_lat)

      min_lat = [(lat - lat_delta), -90.0].max
      max_lat = [(lat + lat_delta), 90.0].min

      scope = Event.not_online
        .where.not(latitude: nil)
        .where.not(longitude: nil)
        .where(latitude: min_lat..max_lat)
        .where.not(
          "lower(unaccent(events.city)) IN (?, ?) AND events.country_id = ?",
          city_name.normalized, city_name.downcase, country_id
        )

      apply_longitude_ranges(scope, lng, lng_delta).distinct.pluck(:city, :country_id)
    end

    # Applies longitude boundary conditions to the query, supporting antimeridian wrapping.
    #
    # @param scope [ActiveRecord::Relation]
    # @param lng [Float] Origin longitude
    # @param lng_delta [Float] Longitude delta in degrees
    #
    # @return [ActiveRecord::Relation]
    def apply_longitude_ranges(scope, lng, lng_delta)
      return scope if lng_delta >= 180.0

      min_lng = lng - lng_delta
      max_lng = lng + lng_delta

      if min_lng < -180.0
        # Wraps across antimeridian on the west: [min_lng + 360, 180] OR [-180, max_lng]
        scope.where(
          "(events.longitude BETWEEN ? AND 180.0) OR (events.longitude BETWEEN -180.0 AND ?)",
          min_lng + 360.0, max_lng
        )
      elsif max_lng > 180.0
        # Wraps across antimeridian on the east: [min_lng, 180] OR [-180, max_lng - 360]
        scope.where(
          "(events.longitude BETWEEN ? AND 180.0) OR (events.longitude BETWEEN -180.0 AND ?)",
          min_lng, max_lng - 360.0
        )
      else
        scope.where(longitude: min_lng..max_lng)
      end
    end

    # Resolves the earliest event's coordinates for each [city, country_id] candidate pair.
    #
    # @param pairs [Array<Array(String, Integer)>] Candidate city pairs
    #
    # @return [Array<Array(String, Integer, Float, Float)>]
    def first_event_coordinates_for(pairs)
      clause = pairs.map { "(events.city = ? AND events.country_id = ?)" }.join(" OR ")
      binds = pairs.flat_map { |city, candidate_country_id| [city, candidate_country_id] }

      Event.not_online
        .where.not(latitude: nil)
        .where.not(longitude: nil)
        .where(clause, *binds)
        .select("DISTINCT ON (events.city, events.country_id) events.city, events.country_id, events.latitude, events.longitude")
        .order("events.city, events.country_id, events.id")
        .map { |e| [e.city, e.country_id, e.latitude, e.longitude] }
    end
  end
end
