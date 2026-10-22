# frozen_string_literal: true

require "test_helper"

class Events::DaysProgressCalculatorTest < ActiveSupport::TestCase
  test "computes total, elapsed, partial, remaining days and percent for an ongoing event" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-15 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-17 00:00:00"),
          time_zone: "America/New_York"
        )

        result = Events::DaysProgressCalculator.call(event)

        assert_equal 3, result[:total]
        assert_equal 1, result[:elapsed]
        assert_equal 1, result[:partial]
        assert_equal 2, result[:remaining]
        assert_equal 33, result[:percent]
      end
    end
  end

  test "class method call delegates to instance call" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-15 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-17 00:00:00"),
          time_zone: "America/New_York"
        )

        instance_result = Events::DaysProgressCalculator.new(event).call
        class_result = Events::DaysProgressCalculator.call(event)

        assert_equal instance_result, class_result
      end
    end
  end

  test "does not leak the event time zone to the process global zone" do
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
        Events::DaysProgressCalculator.call(event)
        assert_equal "UTC", Time.zone.name
      end
    end
  end

  test "computes elapsed and remaining days for a past event" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-20 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-17 00:00:00"),
          time_zone: "America/New_York"
        )

        result = Events::DaysProgressCalculator.call(event)

        assert_equal 3, result[:total]
        assert_equal 6, result[:elapsed]
        assert_equal 6, result[:partial]
        assert_equal(-3, result[:remaining])
        assert_equal 200, result[:percent]
      end
    end
  end

  test "computes elapsed and remaining days for a future event" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-10 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-17 00:00:00"),
          time_zone: "America/New_York"
        )

        result = Events::DaysProgressCalculator.call(event)

        assert_equal 3, result[:total]
        assert_equal(-4, result[:elapsed])
        assert_equal 7, result[:remaining]
        assert_equal(-133, result[:percent])
      end
    end
  end

  test "computes single day event correctly" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-15 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-15 23:59:59"),
          time_zone: "America/New_York"
        )

        result = Events::DaysProgressCalculator.call(event)

        assert_equal 1, result[:total]
        assert_equal 1, result[:elapsed]
        assert_equal 0, result[:remaining]
        assert_equal 100, result[:percent]
      end
    end
  end
end
