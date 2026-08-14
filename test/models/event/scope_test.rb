# frozen_string_literal: true

require "test_helper"

class Event::ScopeTest < ActiveSupport::TestCase
  test "discoverable includes events from the previous UTC day before 04:00 UTC" do
    travel_to Time.zone.parse("2026-08-15 03:59:00") do
      event = create_event_ending_at("2026-08-14 23:59:00")

      assert_includes Event.discoverable, event
    end
  end

  test "discoverable excludes events from the previous UTC day at 04:00 UTC" do
    travel_to Time.zone.parse("2026-08-15 04:00:00") do
      event = create_event_ending_at("2026-08-14 23:59:00")

      assert_not_includes Event.discoverable, event
    end
  end

  test "discoverable includes events ending on the current UTC day" do
    travel_to Time.zone.parse("2026-08-15 04:00:00") do
      event = create_event_ending_at("2026-08-15 00:00:00")

      assert_includes Event.discoverable, event
    end
  end

  test "discoverable excludes events that ended before the previous UTC day" do
    travel_to Time.zone.parse("2026-08-15 03:59:00") do
      event = create_event_ending_at("2026-08-13 23:59:00")

      assert_not_includes Event.discoverable, event
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
