# frozen_string_literal: true

require "test_helper"

class Events::NearbyCitiesQueryTest < ActiveSupport::TestCase
  test "defaults radius_km to 120 km" do
    query = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: countries(:denmark).id)

    assert_equal 120, Events::NearbyCitiesQuery::DEFAULT_RADIUS_KM
    assert_equal 120, query.radius_km
  end

  test "returns cities within the 120 km radius including cross-border and 50-120 km cities" do
    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: countries(:denmark).id).call

    assert_includes result, ["Malmö", countries(:sweden).id]
    assert_includes result, ["Næstved", countries(:denmark).id]
  end

  test "respects a custom radius_km parameter" do
    result = Events::NearbyCitiesQuery.new(
      city_name: "Kopenhago",
      country_id: countries(:denmark).id,
      radius_km: 50
    ).call

    assert_includes result, ["Malmö", countries(:sweden).id]
    assert_not_includes result, ["Næstved", countries(:denmark).id]
  end

  test "excludes cities farther than the radius" do
    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: countries(:denmark).id).call

    assert_not_includes result, ["Aarhuso", countries(:denmark).id]
  end

  test "excludes bounding-box corner cities beyond the radius via Haversine" do
    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: countries(:denmark).id).call

    assert_not_includes result, ["Angulurbo", countries(:sweden).id]
  end

  test "excludes the target city itself" do
    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: countries(:denmark).id).call

    assert_not_includes result, ["Kopenhago", countries(:denmark).id]
  end

  test "returns an empty array when the target city has no coordinates" do
    result = Events::NearbyCitiesQuery.new(city_name: "San Francisco", country_id: countries(:sweden).id).call

    assert_empty result
  end

  test "excludes online events" do
    online = events(:nearby_malmo_future)
    online.update!(online: true)

    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: countries(:denmark).id).call

    assert_not_includes result, ["Malmö", countries(:sweden).id]
  end

  test "includes neighboring cities across the antimeridian from east to west" do
    result = Events::NearbyCitiesQuery.new(city_name: "Orienturbo", country_id: countries(:fiji).id).call

    assert_includes result, ["Okcidenturbo", countries(:fiji).id]
  end

  test "includes neighboring cities across the antimeridian from west to east" do
    result = Events::NearbyCitiesQuery.new(city_name: "Okcidenturbo", country_id: countries(:fiji).id).call

    assert_includes result, ["Orienturbo", countries(:fiji).id]
  end

  test "caches computed nearby cities keyed by country, normalized city, and radius" do
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    query = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: countries(:denmark).id)
    first_result = query.call

    assert Rails.cache.exist?("events/nearby_cities/v2/#{countries(:denmark).id}/kopenhago/120")
    assert_equal first_result, query.call
  ensure
    Rails.cache = original_cache
  end
end
