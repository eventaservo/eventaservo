# frozen_string_literal: true

require "test_helper"

class Admin::MockupsController::CalendarTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
  end

  test "admin can access mockups calendar" do
    sign_in @admin
    get admin_mockups_calendar_url
    assert_response :success
  end

  test "non-admin is redirected to root" do
    sign_in users(:user)
    get admin_mockups_calendar_url
    assert_redirected_to root_path
  end

  test "unauthenticated user is redirected to login" do
    get admin_mockups_calendar_url
    assert_redirected_to new_user_session_path
  end
end
