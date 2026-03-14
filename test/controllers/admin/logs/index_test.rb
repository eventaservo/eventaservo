# frozen_string_literal: true

require "test_helper"

class Admin::LogsController::IndexTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin

    @log1 = Log.create!(
      user: users(:user),
      text: "User logged in",
      created_at: 2.days.ago
    )
    @log2 = Log.create!(
      user: @admin,
      text: "Admin created an event",
      created_at: 1.day.ago
    )
  end

  test "should get index" do
    get admin_logs_url
    assert_response :success
    assert_select ".lead", "Logs"
    assert_select ".row", text: /#{@log1.text}/
    assert_select ".row", text: /#{@log2.text}/
  end

  test "should filter by user_name" do
    get admin_logs_url, params: {user_name: users(:user).name}
    assert_response :success
    assert_select ".row", text: /#{@log1.text}/
    assert_select ".row", text: /#{@log2.text}/, count: 0
  end

  test "should filter by text" do
    get admin_logs_url, params: {text: "created an event"}
    assert_response :success
    assert_select ".row", text: /#{@log1.text}/, count: 0
    assert_select ".row", text: /#{@log2.text}/
  end

  test "should filter by start_date and end_date" do
    get admin_logs_url, params: {start_date: 3.days.ago.to_date.to_s, end_date: 1.day.ago.to_date.to_s}
    assert_response :success
    assert_select ".row", text: /#{@log1.text}/
    assert_select ".row", text: /#{@log2.text}/

    get admin_logs_url, params: {start_date: Date.today.to_s, end_date: Date.tomorrow.to_s}
    assert_response :success
    assert_select ".row", text: /#{@log1.text}/, count: 0
    assert_select ".row", text: /#{@log2.text}/, count: 0
  end

  test "should deny access to non-admin" do
    sign_out @admin
    user = users(:user)
    sign_in user

    get admin_logs_url
    assert_redirected_to root_path
  end

  test "should redirect to login if not authenticated" do
    sign_out @admin
    get admin_logs_url
    assert_redirected_to new_user_session_path
  end
end
