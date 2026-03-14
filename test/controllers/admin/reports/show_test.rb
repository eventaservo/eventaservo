# frozen_string_literal: true

require "test_helper"

class Admin::ReportsController::ShowTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @report = create(:event_report)
  end

  test "should get show" do
    get admin_report_url(@report)
    assert_response :success
    assert_select "div", text: /#{Regexp.escape(@report.title)}/
  end
end
