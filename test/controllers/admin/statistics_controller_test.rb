# frozen_string_literal: true

require "test_helper"

class Admin::StatisticsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, admin: true)
    sign_in @admin
  end

  test "should get index with default range" do
    get admin_statistics_url
    assert_response :success

    expected_start = (Date.today - 11.months).beginning_of_month
    expected_end = Date.today.end_of_month

    assert_equal expected_start, assigns(:start_date)
    assert_equal expected_end, assigns(:end_date)
  end

  test "should get index with custom range" do
    start_date = "2024-01-01"
    end_date = "2024-06-30"

    get admin_statistics_url, params: {start_date: start_date, end_date: end_date}
    assert_response :success

    assert_equal Date.parse(start_date), assigns(:start_date)
    assert_equal Date.parse(end_date), assigns(:end_date)
  end

  test "should swap dates if start_date is after end_date" do
    start_date = "2024-12-31"
    end_date = "2024-01-01"

    get admin_statistics_url, params: {start_date: start_date, end_date: end_date}
    assert_response :success

    assert_equal Date.parse(end_date), assigns(:start_date)
    assert_equal Date.parse(start_date), assigns(:end_date)
  end

  test "should fallback to default range on invalid date" do
    get admin_statistics_url, params: {start_date: "invalid-date", end_date: "2024-01-01"}
    assert_response :success

    expected_start = (Date.today - 11.months).beginning_of_month
    expected_end = Date.today.end_of_month

    assert_equal expected_start, assigns(:start_date)
    assert_equal expected_end, assigns(:end_date)
  end

  test "should deny access to non-admin" do
    sign_out @admin
    user = create(:user, admin: false)
    sign_in user

    get admin_statistics_url
    assert_redirected_to root_path
  end
end
