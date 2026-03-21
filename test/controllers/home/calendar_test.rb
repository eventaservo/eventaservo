# frozen_string_literal: true

require "test_helper"

class HomeController::CalendarTest < ActionDispatch::IntegrationTest
  test "renders calendar view on home page" do
    get root_url
    assert_response :success
    assert_select "[data-controller='events-calendar']"
  end

  test "renders calendar for given date param" do
    get root_url, params: {date: "2026-06-01"}
    assert_response :success
    assert_select "[data-controller='events-calendar']"
  end

  test "renders calendar for invalid date param without error" do
    get root_url, params: {date: "not-a-date"}
    assert_response :success
    assert_select "[data-controller='events-calendar']"
  end

  test "prev navigation link points to 7 days before given date" do
    get root_url, params: {date: "2026-06-01"}
    assert_response :success
    assert_select "a[href*='2026-05-25']"
  end

  test "next navigation link points to 7 days after given date" do
    get root_url, params: {date: "2026-06-01"}
    assert_response :success
    assert_select "a[href*='2026-06-08']"
  end

  test "turbo frame includes the requested date as data attribute" do
    get root_url, params: {date: "2026-06-01"}
    assert_response :success
    assert_select "turbo-frame[data-date='2026-06-01']"
  end

  test "month navigation dropdown lists twelve months from current month start" do
    travel_to Time.zone.parse("2026-03-15 12:00:00") do
      get root_url
      assert_response :success
      assert_select "#calendarMonthNavigation"
      assert_select ".dropdown-menu a[data-turbo-frame='native-calendar']", count: 12
      assert_select ".dropdown-menu a[href*='date=2026-03-01']"
      assert_select ".dropdown-menu a[href*='date=2027-02-01']"
    end
  end
end
