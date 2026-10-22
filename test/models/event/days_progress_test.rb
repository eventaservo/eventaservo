# frozen_string_literal: true

require "test_helper"

class Event::DaysProgressTest < ActiveSupport::TestCase
  test "days_progress computes total, elapsed, remaining days and percent" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-15 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-17 00:00:00"),
          time_zone: "America/New_York"
        )

        result = event.days_progress

        assert_equal 3, result[:total]
        assert_equal 1, result[:elapsed]
        assert_equal 1, result[:partial]
        assert_equal 2, result[:remaining]
        assert_equal 33, result[:percent]
      end
    end
  end

  test "days_progress does not leak the event time zone to the process global zone" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-15 12:00:00") do
        event = build(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-17 00:00:00"),
          time_zone: "America/New_York",
          latitude: nil,
          longitude: nil
        )

        assert_equal "America/New_York", event.time_zone
        assert_equal "UTC", Time.zone.name
        event.days_progress
        assert_equal "UTC", Time.zone.name
      end
    end
  end

  test "days_progress computes elapsed and remaining days for a past event" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-20 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-17 00:00:00"),
          time_zone: "America/New_York"
        )

        result = event.days_progress

        assert_equal 3, result[:total]
        assert_equal 6, result[:elapsed]
        assert_equal 6, result[:partial]
        assert_equal(-3, result[:remaining])
      end
    end
  end

  test "tagoj provides backward-compatible legacy keys" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-15 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-17 00:00:00"),
          time_zone: "America/New_York"
        )

        result = event.tagoj

        assert_equal 3, result[:total]
        assert_equal 1, result[:parcial]
        assert_equal 2, result[:restanta]
        assert_equal 33, result[:percent]
      end
    end
  end
end
