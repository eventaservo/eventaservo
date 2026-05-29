# frozen_string_literal: true

require "test_helper"

class Admin::ReportsController::UpdateTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @report = create(:event_report)
  end

  test "should update report" do
    patch admin_report_url(@report), params: {event_report: {title: "Updated Title"}}
    assert_redirected_to admin_report_path(@report)
    @report.reload
    assert_equal "Updated Title", @report.title
  end
end
