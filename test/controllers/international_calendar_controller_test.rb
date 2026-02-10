# frozen_string_literal: true

require "test_helper"

class InternationalCalendarControllerTest < ActionDispatch::IntegrationTest
  setup do
    @international_event = create(:event, :international_calendar, :future)
    @local_event = create(:event, :future, international_calendar: false)
  end

  test "should get index" do
    get international_calendar_path
    assert_response :success

    assert_match "Internacia Kalendaro", response.body
    assert_match CGI.escapeHTML(@international_event.title), response.body
    refute_match CGI.escapeHTML(@local_event.title), response.body
  end

  test "should get year" do
    # Create an event in the specific year to ensure we're testing data retrieval too
    year = Time.zone.now.year + 1
    event_in_year = create(:event, :international_calendar, date_start: Time.zone.parse("#{year}-06-01 12:00:00"))

    get international_calendar_year_path(year: year)
    assert_response :success
    assert_match CGI.escapeHTML(event_in_year.title), response.body
  end

  test "should redirect for invalid year" do
    get international_calendar_year_path(year: 1800)
    assert_redirected_to root_url
  end
end
