# frozen_string_literal: true

require "test_helper"

class EventsController::ByContinentTest < ActionDispatch::IntegrationTest
  test "renders calendar for reta continent" do
    get events_by_continent_url(continent: "reta")
    assert_response :success
    assert_select "[data-controller='events-calendar']"
  end

  test "renders calendar turbo frame with today as default date for reta continent" do
    get events_by_continent_url(continent: "reta")
    assert_response :success
    assert_select "turbo-frame[data-date='#{Date.current.iso8601}']"
  end

  test "renders calendar for reta continent with given date param" do
    get events_by_continent_url(continent: "reta"), params: {date: "2026-06-01"}
    assert_response :success
    assert_select "turbo-frame[data-date='2026-06-01']"
  end

  test "prev navigation link points to 7 days before given date for reta continent" do
    get events_by_continent_url(continent: "reta"), params: {date: "2026-06-01"}
    assert_response :success
    assert_select "a[href*='2026-05-25']"
  end

  test "next navigation link points to 7 days after given date for reta continent" do
    get events_by_continent_url(continent: "reta"), params: {date: "2026-06-01"}
    assert_response :success
    assert_select "a[href*='2026-06-08']"
  end

  test "does not render calendar for non-reta continents" do
    get events_by_continent_url(continent: "europo")
    assert_response :success
    assert_select "[data-controller='events-calendar']", count: 0
  end
end
