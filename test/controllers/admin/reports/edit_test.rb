# frozen_string_literal: true

require "test_helper"

class Admin::ReportsController::EditTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @report = create(:event_report)
  end

  test "should get edit" do
    get edit_admin_report_url(@report)
    assert_response :success
  end
end
