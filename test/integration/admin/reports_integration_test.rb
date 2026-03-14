# frozen_string_literal: true

require "test_helper"

class Admin::ReportsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @report = create(:event_report)
  end

  test "full report management flow" do
    # 1. Index
    get admin_reports_path
    assert_response :success
    assert_select "div", text: /#{Regexp.escape(@report.event.title)}/

    # 2. Filter
    get admin_reports_path, params: {title: @report.title}
    assert_response :success
    assert_select "div", text: /#{Regexp.escape(@report.title)}/

    # 3. Show
    get admin_report_path(@report)
    assert_response :success
    assert_select "div", text: /#{Regexp.escape(@report.title)}/

    # 4. Edit/Update
    get edit_admin_report_path(@report)
    assert_response :success
    patch admin_report_path(@report), params: {event_report: {title: "New Integrated Title"}}
    assert_redirected_to admin_report_path(@report)
    @report.reload
    assert_equal "New Integrated Title", @report.title

    # 5. Delete
    assert_difference "Event::Report.count", -1 do
      delete admin_report_path(@report)
    end
    assert_redirected_to admin_reports_path
    follow_redirect!
    assert_select "div", text: /New Integrated Title/, count: 0
  end
end
