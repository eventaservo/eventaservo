# frozen_string_literal: true

require "test_helper"

# Covers the X-Robots-Tag and canonical link added by ApplicationController for
# filtered listings, which are the source of the crawler URL explosion.
class HomeController::RobotsHeadersTest < ActionDispatch::IntegrationTest
  KALENDARO = {"Cookie" => "vidmaniero=kalendaro"}

  test "filtered home is marked noindex and points to the clean path" do
    get "/eo", params: {date: "2026-01-01"}, headers: KALENDARO

    assert_response :success
    assert_equal "noindex, follow", response.headers["X-Robots-Tag"]
    assert_includes response.body, %(href="http://www.example.com/eo" rel="canonical")
  end

  test "period and timezone filters are also treated as filtered listings" do
    get "/eo", params: {periodo: "p7_tagojn"}, headers: KALENDARO

    assert_equal "noindex, follow", response.headers["X-Robots-Tag"]
    assert_includes response.body, %(href="http://www.example.com/eo" rel="canonical")

    get "/eo", params: {t: "unutaga"}, headers: KALENDARO

    assert_equal "noindex, follow", response.headers["X-Robots-Tag"]
    assert_includes response.body, %(href="http://www.example.com/eo" rel="canonical")
  end

  test "plain home keeps no directive and no canonical link" do
    get "/eo", headers: KALENDARO

    assert_response :success
    assert_nil response.headers["X-Robots-Tag"]
    refute_includes response.body, "rel=\"canonical\""
  end

  test "directive is set before the response is rendered" do
    get "/eo", params: {date: "2026-01-01"}

    assert_equal "noindex, follow", response.headers["X-Robots-Tag"]
  end

  test "json responses are left untouched" do
    get "/events.json", params: {date: "2026-01-01"}

    assert_nil response.headers["X-Robots-Tag"]
  end
end
