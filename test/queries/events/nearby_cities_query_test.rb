# frozen_string_literal: true

require "test_helper"

class Events::NearbyCitiesQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @denmark = countries(:denmark)
    @sweden = countries(:sweden)
    @fiji = countries(:fiji)

    @copenhagen = create_geo_event(city: "Kopenhago", country: @denmark, latitude: 55.6761, longitude: 12.5683)
    @malmo = create_geo_event(city: "Malmö", country: @sweden, latitude: 55.6050, longitude: 13.0038)
    @naestved = create_geo_event(city: "Næstved", country: @denmark, latitude: 55.2299, longitude: 11.7609)
    @corner = create_geo_event(city: "Angulurbo", country: @sweden, latitude: 56.6761, longitude: 14.3683)
    @aarhus = create_geo_event(city: "Aarhuso", country: @denmark, latitude: 56.1629, longitude: 10.2039)
    @east = create_geo_event(city: "Orienturbo", country: @fiji, latitude: -16.8, longitude: 179.9)
    @west = create_geo_event(city: "Okcidenturbo", country: @fiji, latitude: -16.8, longitude: -179.9)
  end

  test "defaults radius_km to 120 km" do
    query = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: @denmark.id)

    assert_equal 120, Events::NearbyCitiesQuery::DEFAULT_RADIUS_KM
    assert_equal 120, query.radius_km
  end

  test "returns cities within the 120 km radius including cross-border and 50-120 km cities" do
    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: @denmark.id).call

    assert_includes result, ["Malmö", @sweden.id]
    assert_includes result, ["Næstved", @denmark.id]
  end

  test "respects a custom radius_km parameter" do
    result = Events::NearbyCitiesQuery.new(
      city_name: "Kopenhago",
      country_id: @denmark.id,
      radius_km: 50
    ).call

    assert_includes result, ["Malmö", @sweden.id]
    assert_not_includes result, ["Næstved", @denmark.id]
  end

  test "excludes cities farther than the radius" do
    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: @denmark.id).call

    assert_not_includes result, ["Aarhuso", @denmark.id]
  end

  test "excludes bounding-box corner cities beyond the radius via Haversine" do
    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: @denmark.id).call

    assert_not_includes result, ["Angulurbo", @sweden.id]
  end

  test "excludes the target city itself" do
    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: @denmark.id).call

    assert_not_includes result, ["Kopenhago", @denmark.id]
  end

  test "returns an empty array when the target city has no coordinates" do
    result = Events::NearbyCitiesQuery.new(city_name: "San Francisco", country_id: @sweden.id).call

    assert_empty result
  end

  test "ignores events with incomplete coordinates where longitude is nil" do
    create_geo_event(city: "Duonurbo", country: @denmark, latitude: 55.65, longitude: nil)

    assert_empty Events::NearbyCitiesQuery.new(city_name: "Duonurbo", country_id: @denmark.id).call

    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: @denmark.id).call
    assert_not_includes result, ["Duonurbo", @denmark.id]
  end

  test "excludes online events" do
    @malmo.update!(online: true)

    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: @denmark.id).call

    assert_not_includes result, ["Malmö", @sweden.id]
  end

  test "includes neighboring cities across the antimeridian from east to west" do
    result = Events::NearbyCitiesQuery.new(city_name: "Orienturbo", country_id: @fiji.id).call

    assert_includes result, ["Okcidenturbo", @fiji.id]
  end

  test "includes neighboring cities across the antimeridian from west to east" do
    result = Events::NearbyCitiesQuery.new(city_name: "Okcidenturbo", country_id: @fiji.id).call

    assert_includes result, ["Orienturbo", @fiji.id]
  end

  test "handles polar coordinates where longitude delta spans the full globe" do
    create_geo_event(city: "Nordpolurbo", country: @denmark, latitude: 89.99999, longitude: 0.0)
    create_geo_event(city: "Apudpolurbo", country: @sweden, latitude: 89.9, longitude: 120.0)

    result = Events::NearbyCitiesQuery.new(city_name: "Nordpolurbo", country_id: @denmark.id).call

    assert_includes result, ["Apudpolurbo", @sweden.id]
  end

  test "caches computed nearby cities keyed by country, normalized city, and radius" do
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    query = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: @denmark.id)
    first_result = query.call

    assert Rails.cache.exist?("events/nearby_cities/v2/#{@denmark.id}/kopenhago/120")
    assert_equal first_result, query.call
  ensure
    Rails.cache = original_cache
  end

  private

  # Creates an event with explicit coordinates without triggering the test geocoder stub.
  #
  # @param city [String] City name
  # @param country [Country] Country record
  # @param latitude [Float, nil] Latitude coordinate
  # @param longitude [Float, nil] Longitude coordinate
  #
  # @return [Event]
  def create_geo_event(city:, country:, latitude:, longitude:)
    event = Event.new(
      title: "Event in #{city}",
      description: "Test event",
      city: city,
      country: country,
      date_start: 1.month.from_now,
      date_end: 1.month.from_now + 1.day,
      time_zone: "Etc/UTC",
      code: SecureRandom.hex(6),
      site: "https://example.org",
      latitude: latitude,
      longitude: longitude,
      user: @user
    )
    event.instance_variable_set(:@created_from_factory, true)
    event.save!
    event
  end
end
