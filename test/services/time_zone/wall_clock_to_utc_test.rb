# frozen_string_literal: true

require "test_helper"

class TimeZone::WallClockToUtcTest < ActiveSupport::TestCase
  test "converts a non-ambiguous local time to UTC" do
    result = TimeZone::WallClockToUtc.call(
      time_zone: "Europe/Brussels",
      datetime: Time.utc(2026, 5, 16, 12, 0)
    )

    assert result.success?
    assert_equal Time.utc(2026, 5, 16, 10, 0), result.payload
  end

  test "picks the DST occurrence when the local time is ambiguous on fall-back" do
    # Brussels: 03:00 CEST → 02:00 CET on 2026-10-25, so 02:30 happens twice.
    result = TimeZone::WallClockToUtc.call(
      time_zone: "Europe/Brussels",
      datetime: Time.utc(2026, 10, 25, 2, 30)
    )

    assert result.success?
    # DST (CEST = UTC+2) occurrence: 02:30 → 00:30 UTC.
    # Standard (CET = UTC+1) occurrence would be 01:30 UTC.
    assert_equal Time.utc(2026, 10, 25, 0, 30), result.payload
  end

  test "shifts forward by one hour when the local time falls in the spring-forward gap" do
    # Brussels: 02:00 CET → 03:00 CEST on 2026-03-29, so 02:30 does not exist.
    result = TimeZone::WallClockToUtc.call(
      time_zone: "Europe/Brussels",
      datetime: Time.utc(2026, 3, 29, 2, 30)
    )

    assert result.success?
    # 03:30 CEST = 01:30 UTC.
    assert_equal Time.utc(2026, 3, 29, 1, 30), result.payload
  end

  test "ignores the input's zone and reads only the wall-clock components" do
    # An input in NY is treated as if its components were Brussels-local.
    ny_time = Time.new(2026, 5, 16, 12, 0, 0, "-04:00")
    result = TimeZone::WallClockToUtc.call(
      time_zone: "Europe/Brussels",
      datetime: ny_time
    )

    assert result.success?
    # Brussels-local 12:00 in May = CEST (UTC+2) = 10:00 UTC.
    assert_equal Time.utc(2026, 5, 16, 10, 0), result.payload
  end
end
