# frozen_string_literal: true

require "test_helper"

class Events::ByCountryController::ShowTest < ActionDispatch::IntegrationTest
  test "renders by_country page when visitor has a legacy timezone cookie" do
    country = countries(:country_41)

    get events_by_country_url(continent: country.continent.normalized,
      country_name: country.name.normalized),
      headers: {"HTTP_COOKIE" => "horzono=Europe/Kiev"}

    # The before_action rewrites the legacy zone before any view rendering,
    # so the request must not raise even when the page also redirects to
    # set the default view-mode cookie on first visit.
    assert_includes [200, 302], response.status
    assert_equal "Europe/Kyiv", response.cookies["horzono"]
  end

  test "pasintaj=1 lists past events for the country" do
    country = countries(:country_41)
    recent = events(:past_event_danio_recent)
    older = events(:past_event_danio_older)

    get events_by_country_url(continent: country.continent.normalized,
      country_name: country.name.normalized, pasintaj: 1)

    assert_response :success
    assert_match recent.title, response.body
    assert_match older.title, response.body
  end

  test "pasintaj=1 orders past events newest first" do
    country = countries(:country_41)
    recent = events(:past_event_danio_recent)
    older = events(:past_event_danio_older)

    get events_by_country_url(continent: country.continent.normalized,
      country_name: country.name.normalized, pasintaj: 1)

    assert_response :success
    assert response.body.index(recent.title) < response.body.index(older.title),
      "Expected the more-recent past event to appear before the older one"
  end

  test "without pasintaj param the past events do not appear" do
    country = countries(:country_41)
    older = events(:past_event_danio_older)

    get events_by_country_url(continent: country.continent.normalized,
      country_name: country.name.normalized),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}

    assert_response :success
    assert_no_match older.title, response.body
  end

  test "redirects to root when country does not exist" do
    get events_by_country_url(continent: "europo", country_name: "neekzistas")
    assert_redirected_to root_path
    assert_equal "Lando ne ekzistas en la datumbazo", flash[:error]
  end

  test "redirects to root for invalid continent" do
    get events_by_country_url(continent: "atlantido", country_name: "danio")
    assert_redirected_to root_path
    assert_equal "Ne estas eventoj en tiu kontinento", flash[:notice]
  end

  test "renders RSS feed for country" do
    country = countries(:country_41)
    get events_by_country_url(continent: country.continent.normalized,
      country_name: country.name.normalized, format: :xml)
    assert_response :success
    assert_equal "application/xml", response.media_type
  end
end
