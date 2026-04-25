# frozen_string_literal: true

require "test_helper"

class EventsController::ByCountryTest < ActionDispatch::IntegrationTest
  # Regression test for Sentry issue EVENTA-SERVO-1SJ:
  # a visitor arriving with a legacy IANA identifier in the `horzono` cookie
  # caused `ActiveSupport::TimeZone[]` to raise during partial rendering.
  # The ApplicationController before_action now rewrites the cookie so the
  # page renders normally.
  test "renders by_country page when visitor has a legacy timezone cookie" do
    country = Country.find(41) # Danio (Eŭropo)

    get events_by_country_url(continent: country.continent.normalized,
      country_name: country.name.normalized),
      headers: {"HTTP_COOKIE" => "horzono=Europe/Kiev"}

    # The before_action rewrites the legacy zone before any view rendering,
    # so the request must not raise even when the page also redirects to
    # set the default view-mode cookie on first visit.
    assert_includes [200, 302], response.status
    assert_equal "Europe/Kyiv", response.cookies["horzono"]
  end
end
