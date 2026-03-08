# frozen_string_literal: true

require "test_helper"

class Admin::MockupsController::IndexTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
  end

  test "admin can access mockups index" do
    get admin_mockups_url
    assert_response :success
  end

  test "non-admin is redirected to root" do
    sign_out @admin
    sign_in users(:user)

    get admin_mockups_url
    assert_redirected_to root_path
  end

  test "unauthenticated user is redirected to login" do
    sign_out @admin

    get admin_mockups_url
    assert_redirected_to new_user_session_path
  end
end
