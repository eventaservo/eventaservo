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

  test "sets default view cookie on first visit" do
    get events_by_city_url(continent: "azio",
      country_name: "afganio",
      city_name: "new york")
    assert_response :success
    assert_equal "kartaro", response.cookies["vidmaniero"]
  end

  test "hodiau filter includes evening event for New York visitor" do
    travel_to Time.utc(2026, 8, 14, 12, 0) do
      country = countries(:denmark)
      Event.create!(
        title: "Evening Event Copenhagen",
        description: "Test",
        city: "Kopenhago",
        country: country,
        format: :onsite,
        date_start: Time.zone.parse("2026-08-14 20:00:00"),
        date_end: Time.zone.parse("2026-08-14 21:00:00"),
        time_zone: "America/New_York",
        code: SecureRandom.hex(6),
        site: "https://test.example.com",
        user: users(:user)
      )

      cookies[:horzono] = "America/New_York"
      cookies[:vidmaniero] = "kartoj"
      get events_by_city_url(continent: country.continent.normalized, country_name: country.name.normalized,
        city_name: "kopenhago", periodo: "hodiau")

      assert_response :success
      assert_match(/Evening Event Copenhagen/, response.body)
    end
  end
end
