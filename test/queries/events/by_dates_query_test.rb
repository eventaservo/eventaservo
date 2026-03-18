# frozen_string_literal: true

require "test_helper"

class Events::ByDatesQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @country_id = 1
    @window_start = Date.new(2026, 3, 15) # Sunday
    @window_end = Date.new(2026, 3, 21)   # Saturday
  end

  # -- Single-day event --

  test "single-day event within window appears on exactly one day" do
    event = create_event(
      title: "One Day Event",
      date_start: Time.utc(2026, 3, 17, 10, 0),
      date_end: Time.utc(2026, 3, 17, 18, 0)
    )

    result = query.call

    assert_includes result[Date.new(2026, 3, 17)], event
    days_with_event = result.count { |_, events| events.include?(event) }
    assert_equal 1, days_with_event
  end

  # -- Multi-day event fully within window --

  test "multi-day event fully within window appears on each day" do
    event = create_event(
      title: "Three Day Event",
      date_start: Time.utc(2026, 3, 16, 9, 0),
      date_end: Time.utc(2026, 3, 18, 17, 0)
    )

    result = query.call

    assert_includes result[Date.new(2026, 3, 16)], event
    assert_includes result[Date.new(2026, 3, 17)], event
    assert_includes result[Date.new(2026, 3, 18)], event
    assert_not_includes result[Date.new(2026, 3, 15)], event
    assert_not_includes result[Date.new(2026, 3, 19)], event
  end

  # -- THE BUG: multi-day event starting before window --

  test "multi-day event starting before window appears from window start" do
    event = create_event(
      title: "Started Before",
      date_start: Time.utc(2026, 3, 13, 15, 0),
      date_end: Time.utc(2026, 3, 17, 10, 0)
    )

    result = query.call

    assert_includes result[Date.new(2026, 3, 15)], event
    assert_includes result[Date.new(2026, 3, 16)], event
    assert_includes result[Date.new(2026, 3, 17)], event
    assert_not_includes result[Date.new(2026, 3, 18)], event
  end

  # -- Multi-day event ending after window --

  test "multi-day event ending after window appears until window end" do
    event = create_event(
      title: "Ends After",
      date_start: Time.utc(2026, 3, 19, 9, 0),
      date_end: Time.utc(2026, 3, 25, 17, 0)
    )

    result = query.call

    assert_not_includes result[Date.new(2026, 3, 18)], event
    assert_includes result[Date.new(2026, 3, 19)], event
    assert_includes result[Date.new(2026, 3, 20)], event
    assert_includes result[Date.new(2026, 3, 21)], event
  end

  # -- Event spanning entire window --

  test "event spanning entire window appears on all days" do
    event = create_event(
      title: "Spans Everything",
      date_start: Time.utc(2026, 3, 10, 9, 0),
      date_end: Time.utc(2026, 3, 28, 17, 0)
    )

    result = query.call

    (@window_start..@window_end).each do |day|
      assert_includes result[day], event, "Expected event on #{day}"
    end
  end

  # -- Event outside window --

  test "event completely outside window does not appear" do
    event = create_event(
      title: "Outside",
      date_start: Time.utc(2026, 3, 25, 9, 0),
      date_end: Time.utc(2026, 3, 26, 17, 0)
    )

    result = query.call

    result.each_value do |events|
      assert_not_includes events, event
    end
  end

  # -- Sorting: all-day first --

  test "all-day events sorted before timed events within a day" do
    all_day = create_event(
      title: "All Day",
      date_start: Time.utc(2026, 3, 17, 0, 0),
      date_end: Time.utc(2026, 3, 18, 0, 0)
    )
    timed = create_event(
      title: "Morning Event",
      date_start: Time.utc(2026, 3, 17, 8, 0),
      date_end: Time.utc(2026, 3, 17, 10, 0)
    )

    result = query.call
    day_events = result[Date.new(2026, 3, 17)]

    assert day_events.index(all_day) < day_events.index(timed),
      "All-day event should appear before timed event"
  end

  # -- Every day has a key --

  test "every day in the range has a key even if empty" do
    result = query.call

    (@window_start..@window_end).each do |day|
      assert result.key?(day), "Expected key for #{day}"
      assert_kind_of Array, result[day]
    end
  end

  # -- Timezone affects day grouping --

  test "user timezone affects which day the event appears on" do
    # 2026-03-17 23:00 UTC = 2026-03-18 08:00 in Asia/Tokyo (+9)
    event = create_event(
      title: "Late UTC Event",
      date_start: Time.utc(2026, 3, 17, 23, 0),
      date_end: Time.utc(2026, 3, 18, 1, 0),
      time_zone: "Etc/UTC",
      online: true,
      city: "Reta"
    )

    result_utc = query(timezone: "Etc/UTC").call
    result_tokyo = query(timezone: "Asia/Tokyo").call

    assert_includes result_utc[Date.new(2026, 3, 17)], event
    assert_includes result_tokyo[Date.new(2026, 3, 18)], event
  end

  # -- Invalid timezone fallback --

  test "invalid user timezone falls back to event timezone" do
    event = create_event(
      title: "Timezone Fallback",
      date_start: Time.utc(2026, 3, 17, 10, 0),
      date_end: Time.utc(2026, 3, 17, 12, 0),
      time_zone: "Etc/UTC"
    )

    result = query(timezone: "Invalid/Timezone").call

    assert_includes result[Date.new(2026, 3, 17)], event
  end

  # -- Scope is respected --

  test "scope filtering is respected" do
    event = create_event(
      title: "Cancelled Event",
      date_start: Time.utc(2026, 3, 17, 10, 0),
      date_end: Time.utc(2026, 3, 17, 12, 0),
      cancelled: true
    )

    result = Events::ByDatesQuery.new(
      from: @window_start,
      to: @window_end,
      scope: Event.ne_nuligitaj
    ).call

    assert_not_includes result[Date.new(2026, 3, 17)], event
  end

  # -- Single-day window --

  test "single-day window works correctly" do
    event = create_event(
      title: "Today Event",
      date_start: Time.utc(2026, 3, 15, 10, 0),
      date_end: Time.utc(2026, 3, 15, 12, 0)
    )

    result = Events::ByDatesQuery.new(
      from: @window_start,
      to: @window_start,
      scope: Event.all
    ).call

    assert_equal 1, result.size
    assert_includes result[@window_start], event
  end

  # -- Default scope --

  test "default scope uses venontaj and chefaj" do
    past_event = create_event(
      title: "Past Event",
      date_start: Time.utc(2025, 1, 1, 10, 0),
      date_end: Time.utc(2025, 1, 1, 12, 0)
    )

    result = Events::ByDatesQuery.new(
      from: Date.new(2025, 1, 1),
      to: Date.new(2025, 1, 7)
    ).call

    assert_not_includes result[Date.new(2025, 1, 1)], past_event
  end

  private

  def query(timezone: nil)
    Events::ByDatesQuery.new(
      from: @window_start,
      to: @window_end,
      scope: Event.all,
      timezone: timezone
    )
  end

  def create_event(title:, date_start:, date_end:, time_zone: "Etc/UTC", **attrs)
    Event.create!(
      title: title,
      description: "Test event",
      city: "Test City",
      country_id: @country_id,
      date_start: date_start,
      date_end: date_end,
      time_zone: time_zone,
      code: SecureRandom.hex(6),
      site: "https://test.example.com",
      user: @user,
      **attrs
    )
  end
end
