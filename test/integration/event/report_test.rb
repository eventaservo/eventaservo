require "test_helper"

class Event::ReportIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = FactoryBot.create(:user)
    @event = FactoryBot.create(:event, :past, user: @user)
    sign_in @user
  end

  test "do not display reports for future events" do
    future_event = FactoryBot.create(:event, :venonta, user: @user)
    get event_path(future_event.code)
    assert_select "span", future_event.title
    assert_select "div", text: "📸 Raportoj", count: 0
  end

  test "display reports sidebar for past (or on-going) events" do
    get event_path(@event.code)
    assert_select "span", @event.title
    assert_select "div", "📸 Raportoj"
  end

  test "create, update and delete report" do
    report_data = {event_report: {title: "Report title", content: "Report content"}}
    post event_reports_path(@event.code), params: report_data
    assert_redirected_to event_path(@event.code)
    follow_redirect!
    assert_select "a", "Report title"
    assert_select "i", "- #{@user.name}"
    assert_select "a", "Aldoni raporton"

    report = Event::Report.last
    put event_report_path(@event.code, report), params: {event_report: {title: "New report title"}}
    get event_path(@event.code)
    assert_select "a", "New report title"

    delete event_report_path(@event.code, report)
    get event_path(@event.code)
    assert_select "a", text: "New report title", count: 0
  end
end
