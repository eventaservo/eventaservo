# frozen_string_literal: true

require "test_helper"

class EventsController::ByCountryTest < ActionDispatch::IntegrationTest
  # Regression test for Sentry issues EVENTA-SERVO-1SJ and EVENTA-SERVO-1TJ:
  # a visitor arriving with a legacy IANA identifier in the `horzono` cookie
  # caused `ActiveSupport::TimeZone[]` to raise during partial rendering.
  # The ApplicationController before_action now self-heals the cookie so the
  # page renders normally.
  test "renders by_country page when visitor has a legacy timezone cookie" do
    country = Country.find(41) # Danio (Eŭropo)

    cookies[:horzono] = "Europe/Kiev"

    get events_by_country_url(continent: country.continent.normalized,
      country_name: country.name.normalized)

    # First visit redirects to set the default view mode cookie.
    follow_redirect! if response.redirect?
    assert_response :success
  end
end
