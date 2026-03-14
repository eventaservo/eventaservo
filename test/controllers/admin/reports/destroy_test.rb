# frozen_string_literal: true

require "test_helper"

class Admin::ReportsController::DestroyTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @report = create(:event_report)
  end

  test "should destroy report" do
    assert_difference "Event::Report.count", -1 do
      delete admin_report_url(@report)
    end
    assert_redirected_to admin_reports_path
  end
end
