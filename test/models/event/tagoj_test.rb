# frozen_string_literal: true

require "test_helper"

class Event::TagojTest < ActiveSupport::TestCase
  test "tagoj computes total, partial, remaining days and percent" do
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

  test "tagoj does not leak the event time zone to the process global zone" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-15 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-17 00:00:00"),
          time_zone: "America/New_York"
        )

        assert_equal "UTC", Time.zone.name
        event.tagoj
        assert_equal "UTC", Time.zone.name
      end
    end
  end

  test "tagoj returns zero partial days for a past event" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-20 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-17 00:00:00"),
          time_zone: "America/New_York"
        )

        result = event.tagoj

        assert_equal 3, result[:total]
        assert_equal 6, result[:parcial]
        assert_equal(-3, result[:restanta])
      end
    end
  end
end
