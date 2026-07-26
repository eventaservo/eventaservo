# frozen_string_literal: true

require "test_helper"

class Events::NearbyCitiesQueryTest < ActiveSupport::TestCase
  test "returns cities within the radius, even across borders" do
    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: countries(:denmark).id).call

    assert_includes result, ["Malmö", countries(:sweden).id]
  end

  test "excludes cities farther than the radius" do
    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: countries(:denmark).id).call

    assert_not_includes result, ["Aarhuso", countries(:denmark).id]
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
    online = events(:malmo_future)
    online.update!(online: true)

    result = Events::NearbyCitiesQuery.new(city_name: "Kopenhago", country_id: countries(:denmark).id).call

    assert_not_includes result, ["Malmö", countries(:sweden).id]
  end
end
