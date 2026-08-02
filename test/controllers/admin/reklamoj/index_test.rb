# frozen_string_literal: true

require "test_helper"

class Admin::ReklamojController::IndexTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @user = users(:user)
  end

  test "admin can access reklamoj index" do
    sign_in @admin
    get admin_reklamoj_index_url
    assert_response :success
  end

  test "non-admin is redirected to root" do
    sign_in @user
    get admin_reklamoj_index_url
    assert_redirected_to root_path
  end

  test "unauthenticated user is redirected to login" do
    get admin_reklamoj_index_url
    assert_redirected_to new_user_session_path
  end
end
