# frozen_string_literal: true

require "test_helper"

class Events::ByCityController::ShowTest < ActionDispatch::IntegrationTest
  test "pasintaj=1 lists past events for the city" do
    country = countries(:denmark)
    recent = events(:past_event_danio_recent)

    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: recent.city,
      pasintaj: 1)

    assert_response :success
    assert_match recent.title, response.body
  end

  test "pasintaj=1 excludes events from other cities" do
    country = countries(:denmark)
    recent = events(:past_event_danio_recent)
    older = events(:past_event_danio_older) # in a different city

    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: recent.city,
      pasintaj: 1)

    assert_response :success
    assert_no_match older.title, response.body
  end

  test "redirects to root when country does not exist" do
    get events_by_city_url(continent: "europo", country_name: "neekzistas", city_name: "kopenhago")
    assert_redirected_to root_path
    assert_equal "Lando ne ekzistas", flash[:error]
  end

  test "redirects to root for invalid continent" do
    get events_by_city_url(continent: "atlantido", country_name: "danio", city_name: "kopenhago")
    assert_redirected_to root_path
    assert_equal "Ne estas eventoj en tiu kontinento", flash[:notice]
  end

  test "renders kartaro view for city with future events" do
    get events_by_city_url(continent: "azio",
      country_name: "afganio",
      city_name: "new york"),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}
    assert_response :success
    assert_match events(:valid_event).title, response.body
  end

  test "redirects to set default view cookie on first visit" do
    get events_by_city_url(continent: "azio",
      country_name: "afganio",
      city_name: "new york")
    assert_response :redirect
    assert_includes CGI.unescape(response.location), "new york"
  end
end
