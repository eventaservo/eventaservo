# frozen_string_literal: true

require "test_helper"

class ReportsIntegrationTest < ActionDispatch::IntegrationTest
  test "list only events with reports" do
    event_without_report = create(:event)
    event_with_report = create(:event_report).event

    get reports_url
    assert_response :success
    assert_select "div.lead", text: "Eventoj kun raportoj"
    assert_select "a.link-blue", text: event_with_report.title
    assert_select "a.link-blue", {count: 0, text: event_without_report.title}
  end
end
