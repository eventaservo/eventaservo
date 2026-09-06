# frozen_string_literal: true

require "test_helper"

class Event::ScopeTest < ActiveSupport::TestCase
  test "venontaj with New York tz includes event ending on the previous UTC day" do
    travel_to Time.zone.parse("2026-08-15 03:00:00") do
      event = create_event_ending_at("2026-08-14 23:00:00")

      assert_includes Event.venontaj("America/New_York"), event
      assert_not_includes Event.venontaj, event
    end
  end

  test "today with New York tz includes event at 20:00 EDT that is 00:00 UTC next day" do
    travel_to Time.zone.parse("2026-08-14 12:00:00") do
      event = create(
        :event,
        date_start: Time.zone.parse("2026-08-15 00:00:00"),
        date_end: Time.zone.parse("2026-08-15 01:00:00"),
        time_zone: "America/New_York"
      )

      assert_includes Event.today("America/New_York"), event
      assert_not_includes Event.today, event
    end
  end

  test "today without tz keeps UTC behavior" do
    travel_to Time.zone.parse("2026-08-14 12:00:00") do
      event = create(
        :event,
        date_start: Time.zone.parse("2026-08-14 23:00:00"),
        date_end: Time.zone.parse("2026-08-14 23:30:00"),
        time_zone: "America/New_York"
      )

      assert_includes Event.today, event
      assert_includes Event.today("America/New_York"), event
    end
  end

  test "not_today with New York tz excludes event that is already next day in UTC" do
    travel_to Time.zone.parse("2026-08-14 12:00:00") do
      event = create(
        :event,
        date_start: Time.zone.parse("2026-08-15 00:00:00"),
        date_end: Time.zone.parse("2026-08-15 01:00:00"),
        time_zone: "America/New_York"
      )

      assert_not_includes Event.not_today("America/New_York"), event
      assert_includes Event.not_today, event
    end
  end

  test "venontaj excludes events from the previous UTC day" do
    travel_to Time.zone.parse("2026-08-15 03:59:00") do
      event = create_event_ending_at("2026-08-14 23:59:00")

      assert_not_includes Event.venontaj, event
    end
  end

  private

  # Creates an event with a fixed end time for scope boundary tests.
  #
  # @param date_end [String] UTC end time
  # @return [Event]
  def create_event_ending_at(date_end)
    end_time = Time.zone.parse(date_end)

    create(
      :event,
      date_start: end_time - 1.hour,
      date_end: end_time
    )
  end
end
