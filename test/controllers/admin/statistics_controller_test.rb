require "test_helper"

class Admin::StatisticsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @user = users(:user)
  end

  test "should redirect index when not logged in" do
    get admin_statistics_url
    assert_redirected_to new_user_session_url
  end

  test "should redirect index when logged in as normal user" do
    sign_in @user
    get admin_statistics_url
    assert_redirected_to root_url
  end

  test "should get index when logged in as admin" do
    sign_in @admin
    get admin_statistics_url
    assert_response :success
  end

  test "should get index with custom start and end dates" do
    sign_in @admin
    get admin_statistics_url, params: {start_date: "2023-01-01", end_date: "2023-12-31"}
    assert_response :success
  end

  test "should swap start and end dates if start is greater than end" do
    sign_in @admin
    get admin_statistics_url, params: {start_date: "2023-12-31", end_date: "2023-01-01"}
    assert_response :success
  end

  test "should fallback to defaults with invalid dates" do
    sign_in @admin
    get admin_statistics_url, params: {start_date: "invalid", end_date: "not-a-date"}
    assert_response :success
  end
end
