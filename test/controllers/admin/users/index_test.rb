# frozen_string_literal: true

require "test_helper"

class Admin::UsersController::IndexTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
  end

  test "should get index" do
    get admin_users_url
    assert_response :success
  end

  test "should filter by name" do
    get admin_users_url, params: {name: users(:user).name}
    assert_response :success
  end

  test "should filter by email" do
    get admin_users_url, params: {email: users(:user).email}
    assert_response :success
  end

  test "should filter by username" do
    get admin_users_url, params: {username: users(:user).username}
    assert_response :success
  end

  test "should filter by scope disabled" do
    get admin_users_url, params: {scope: "disabled"}
    assert_response :success
  end

  test "should filter by scope abandoned" do
    get admin_users_url, params: {scope: "abandoned"}
    assert_response :success
  end

  test "should filter by scope not_confirmed" do
    get admin_users_url, params: {scope: "not_confirmed"}
    assert_response :success
  end

  test "should deny access to non-admin" do
    sign_out @admin
    sign_in users(:user)
    get admin_users_url
    assert_redirected_to root_path
  end
end
