# frozen_string_literal: true

require "test_helper"

class Admin::MockupsController::ButtonsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
  end

  test "admin can access buttons mockup" do
    get admin_mockups_buttons_url
    assert_response :success
  end

  test "non-admin is redirected to root" do
    sign_out @admin
    sign_in users(:user)

    get admin_mockups_buttons_url
    assert_redirected_to root_path
  end

  test "unauthenticated user is redirected to login" do
    sign_out @admin

    get admin_mockups_buttons_url
    assert_redirected_to new_user_session_path
  end
end
