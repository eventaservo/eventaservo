# frozen_string_literal: true

require "test_helper"

class EventsController::ByCityTest < ActionDispatch::IntegrationTest
  test "redirects to home page when country does not exist" do
    get events_by_city_url(continent: "europo", country_name: "non_existent_country", city_name: "some_city")

    assert_redirected_to root_url
    assert_equal "Lando ne ekzistas", flash[:error]
  end

  test "redirects to set vidmaniero cookie if it is missing" do
    country = Country.find_by!(name: "Afganio")
    city = "Kabul"

    # We create an event so the view has something to render if it didn't redirect
    create(:event, city: city, country: country)

    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized, city_name: city)

    assert_response :redirect
    assert_equal "kartaro", response.cookies["vidmaniero"]
    assert_redirected_to events_by_city_url(continent: country.continent.normalized, country_name: country.name.downcase, city_name: city.downcase)
  end

  test "renders successfully when vidmaniero cookie is present" do
    country = Country.find_by!(name: "Afganio")
    city = "Kabul"

    create(:event, city: city, country: country)

    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized, city_name: city),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}

    assert_response :success

    test "pasintaj=1 lists past events for the city" do
    country = Country.find(41) # Danio
    recent = events(:past_event_danio_recent)

    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: recent.city,
      pasintaj: 1)

    assert_response :success
    assert_match recent.title, response.body
  end

  test "pasintaj=1 excludes events from other cities" do
    country = Country.find(41) # Danio
    recent = events(:past_event_danio_recent)
    older = events(:past_event_danio_older) # in a different city

    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: recent.city,
      pasintaj: 1)

    assert_response :success
    assert_no_match older.title, response.body
  end
end
