# frozen_string_literal: true

require "test_helper"

class Admin::LogsController::IndexTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin

    @user = users(:user)
    # Log 1: Without associations
    @log1 = Log.create!(
      user: @user,
      text: "User action",
      created_at: Time.zone.parse("2026-03-10 10:00:00")
    )

    @org = Organization.find_or_create_by!(short_name: "test-org") do |o|
      o.name = "Test Org"
    end
    @event = events(:valid_event)

    # Log 2: With event and organization
    @log2 = Log.create!(
      user: @admin,
      text: "Admin update",
      created_at: Time.zone.parse("2026-03-12 15:00:00"),
      metadata: {event_id: @event.id, organization_id: @org.id}
    )

    # Log 3: With the same event (to test .uniq and pre-load)
    @log3 = Log.create!(
      user: @admin,
      text: "Another update",
      created_at: Time.zone.parse("2026-03-13 10:00:00"),
      metadata: {event_id: @event.id}
    )
  end

  test "should get index" do
    get admin_logs_url
    assert_response :success
    assert_select ".lead", "Logs"
    assert_select "div.px-2.py-1", text: /#{@log1.text}/
    assert_select "div.px-2.py-1", text: /#{@log2.text}/
    assert_select "div.px-2.py-1", text: /#{@log3.text}/

    # Verify if the links were rendered correctly using the pre-load
    assert_select "a", text: "Evento", count: 2
    assert_select "a", text: "Organizo", count: 1
  end

  test "should use query object for filtering" do
    get admin_logs_url, params: {user_name: @user.name}
    assert_response :success
    assert_select "div.px-2.py-1", text: /#{@log1.text}/
    assert_select "div.px-2.py-1", text: /#{@log2.text}/, count: 0
  end

  test "should handle invalid date filters without crashing" do
    get admin_logs_url, params: {start_date: "invalid-date", end_date: "also-invalid"}
    assert_response :success
    assert_select "div.px-2.py-1", text: /#{@log1.text}/
    assert_select "div.px-2.py-1", text: /#{@log2.text}/
  end

  test "should show empty state when no logs found" do
    get admin_logs_url, params: {text: "non-existent-text"}
    assert_response :success
    assert_select "p", "Neniu protokolo trovita."
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
