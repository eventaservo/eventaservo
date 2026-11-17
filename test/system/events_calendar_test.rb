# frozen_string_literal: true

require "application_system_test_case"

# System tests for the native week-list calendar Stimulus controller and Turbo Frame navigation.
class EventsCalendarSystemTest < ApplicationSystemTestCase
  test "hovering event and navigation links does not dim or lock the calendar" do
    event = events(:esperanto_meetup)

    visit root_path(date: event.date_start.to_date.iso8601)
    assert_selector "turbo-frame#native-calendar"

    event_link = find("turbo-frame#native-calendar a[href='#{event_path(code: event.ligilo)}']", match: :first)
    event_link.hover
    sleep 0.35

    assert_no_selector "turbo-frame#native-calendar.calendar--loading"
    assert_equal "1", evaluate_script("getComputedStyle(document.getElementById('native-calendar')).opacity")
    assert_equal "auto", evaluate_script("getComputedStyle(document.getElementById('native-calendar')).pointerEvents")

    next_week_link = find("turbo-frame#native-calendar a[aria-label='#{I18n.t("events.calendar.next_week")}']", match: :first)
    next_week_link.hover
    sleep 0.35

    assert_no_selector "turbo-frame#native-calendar.calendar--loading"

    event_link.click
    assert_current_path event_path(code: event.ligilo)
    assert_text event.title
  end

  test "navigating weeks inside calendar loads next week and clears loading state" do
    start_date = events(:esperanto_meetup).date_start.to_date
    next_week_date = start_date + 7.days

    visit root_path(date: start_date.iso8601)
    assert_selector "turbo-frame#native-calendar a[href*='date=#{next_week_date.iso8601}']"

    find("turbo-frame#native-calendar a[aria-label='#{I18n.t("events.calendar.next_week")}']", match: :first).click

    assert_selector "turbo-frame#native-calendar a[href*='date=#{(next_week_date + 7.days).iso8601}']"
    sleep 0.35
    assert_no_selector "turbo-frame#native-calendar.calendar--loading"
  end
end
