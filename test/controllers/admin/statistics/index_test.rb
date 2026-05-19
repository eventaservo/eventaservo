# frozen_string_literal: true

require "test_helper"

class Admin::StatisticsController::IndexTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
  end

  test "should get index with default range" do
    get admin_statistics_url
    assert_response :success

    expected_start = (Date.today - 11.months).beginning_of_month
    expected_end = Date.today.end_of_month

    assert_select "input#start_date" do
      assert_select "[value=?]", expected_start.to_s
    end
    assert_select "input#end_date" do
      assert_select "[value=?]", expected_end.to_s
    end
  end

  test "should get index with custom range" do
    start_date = "2024-01-01"
    end_date = "2024-06-30"

    get admin_statistics_url, params: {start_date: start_date, end_date: end_date}
    assert_response :success

    assert_select "input#start_date" do
      assert_select "[value=?]", start_date
    end
    assert_select "input#end_date" do
      assert_select "[value=?]", end_date
    end
  end

  test "should swap dates if start_date is after end_date" do
    start_date = "2024-12-31"
    end_date = "2024-01-01"

    get admin_statistics_url, params: {start_date: start_date, end_date: end_date}
    assert_response :success

    assert_select "input#start_date" do
      assert_select "[value=?]", end_date
    end
    assert_select "input#end_date" do
      assert_select "[value=?]", start_date
    end
  end

  test "should fallback to default range on invalid date" do
    # Use two invalid dates to trigger full default range
    get admin_statistics_url, params: {start_date: "invalid", end_date: "invalid"}
    assert_response :success

    expected_start = (Date.today - 11.months).beginning_of_month
    expected_end = Date.today.end_of_month

    assert_select "input#start_date" do
      assert_select "[value=?]", expected_start.to_s
    end
    assert_select "input#end_date" do
      assert_select "[value=?]", expected_end.to_s
    end
  end

  test "should deny access to non-admin" do
    sign_out @admin
    user = users(:user)
    sign_in user

    get admin_statistics_url
    assert_redirected_to root_path
  end

  test "should redirect to login if not authenticated" do
    sign_out @admin
    get admin_statistics_url
    assert_redirected_to new_user_session_path
  end
end
