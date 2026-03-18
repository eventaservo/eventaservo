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
end
