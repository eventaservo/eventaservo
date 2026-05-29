# frozen_string_literal: true

require "test_helper"

class Admin::ReportsController::IndexTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @report = create(:event_report)
  end

  test "should get index" do
    get admin_reports_url
    assert_response :success
    assert_select "div", text: /#{Regexp.escape(@report.event.title)}/
  end

  test "should filter by title" do
    get admin_reports_url, params: {title: @report.title}
    assert_response :success
    assert_select "div", text: /#{Regexp.escape(@report.title)}/
  end

  test "should deny access to non-admin" do
    sign_out @admin
    sign_in users(:user)
    get admin_reports_url
    assert_redirected_to root_path
  end
end
