# frozen_string_literal: true

require "test_helper"

class Events::ByCountryController::ShowTest < ActionDispatch::IntegrationTest
  test "renders by_country page when visitor has a legacy timezone cookie" do
    country = Country.find(41) # Danio (Eŭropo)

    get events_by_country_url(continent: country.continent.normalized,
      country_name: country.name.normalized),
      headers: {"HTTP_COOKIE" => "horzono=Europe/Kiev"}

    assert_includes [200, 302], response.status
    assert_equal "Europe/Kyiv", response.cookies["horzono"]
  end

  test "pasintaj=1 lists past events for the country" do
    country = Country.find(41) # Danio
    recent = events(:past_event_danio_recent)
    older = events(:past_event_danio_older)

    get events_by_country_url(continent: country.continent.normalized,
      country_name: country.name.normalized, pasintaj: 1)

    assert_response :success
    assert_match recent.title, response.body
    assert_match older.title, response.body
  end

  test "pasintaj=1 orders past events newest first" do
    country = Country.find(41) # Danio
    recent = events(:past_event_danio_recent)
    older = events(:past_event_danio_older)

    get events_by_country_url(continent: country.continent.normalized,
      country_name: country.name.normalized, pasintaj: 1)

    assert_response :success
    assert response.body.index(recent.title) < response.body.index(older.title),
      "Expected the more-recent past event to appear before the older one"
  end

  test "without pasintaj param the past events do not appear" do
    country = Country.find(41) # Danio
    older = events(:past_event_danio_older)

    get events_by_country_url(continent: country.continent.normalized,
      country_name: country.name.normalized),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}

    assert_response :success
    assert_no_match older.title, response.body
  end
end
