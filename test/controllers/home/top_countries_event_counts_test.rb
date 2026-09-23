# frozen_string_literal: true

require "test_helper"

# Tests the private controller helper that feeds the top countries chart.
class HomeController::TopCountriesEventCountsTest < ActionDispatch::IntegrationTest
  test "returns the top countries and their event counts" do
    result = HomeController.new.send(:top_countries_event_counts)

    assert_includes result[:countries], "Afganio"
    assert_includes result[:counts], 2
    assert_equal result[:countries].length, result[:counts].length
  end
end
