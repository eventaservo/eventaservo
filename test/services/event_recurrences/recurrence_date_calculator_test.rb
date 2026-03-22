# frozen_string_literal: true

require "test_helper"

class EventRecurrences::RecurrenceDateCalculatorTest < ActiveSupport::TestCase
  # -- Daily --

  test "daily: generates dates every day" do
    recurrence = build_recurrence(frequency: "daily", interval: 1)
    dates = calculate(recurrence, from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 8))

    assert_equal 7, dates.size
    assert_equal Date.new(2026, 3, 2), dates.first
    assert_equal Date.new(2026, 3, 8), dates.last
  end

  test "daily: generates dates every 3 days" do
    recurrence = build_recurrence(frequency: "daily", interval: 3)
    dates = calculate(recurrence, from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 15))

    assert_equal [
      Date.new(2026, 3, 4),
      Date.new(2026, 3, 7),
      Date.new(2026, 3, 10),
      Date.new(2026, 3, 13)
    ], dates
  end

  test "daily: returns empty when window is too small" do
    recurrence = build_recurrence(frequency: "daily", interval: 10)
    dates = calculate(recurrence, from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 5))

    assert_empty dates
  end

  # -- Weekly --

  test "weekly: generates dates on specific days of week" do
    # Tuesday (2) and Thursday (4)
    recurrence = build_recurrence(frequency: "weekly", interval: 1, days_of_week: [2, 4])
    # 2026-03-01 is a Sunday
    dates = calculate(recurrence, from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 15))

    expected_dates = [
      Date.new(2026, 3, 3),  # Tuesday
      Date.new(2026, 3, 5),  # Thursday
      Date.new(2026, 3, 10), # Tuesday
      Date.new(2026, 3, 12)  # Thursday
    ]
    assert_equal expected_dates, dates
  end

  test "weekly: every 2 weeks on Monday" do
    # Monday = 1
    recurrence = build_recurrence(frequency: "weekly", interval: 2, days_of_week: [1])
    # 2026-03-02 is Monday
    dates = calculate(recurrence, from: Date.new(2026, 3, 1), to: Date.new(2026, 4, 15))

    # Weeks starting from 2026-03-01 (Sunday): Mar 2, then skip a week, Mar 16, skip, Mar 30, skip, Apr 13
    assert_includes dates, Date.new(2026, 3, 2)
    assert_includes dates, Date.new(2026, 3, 16)
    assert_includes dates, Date.new(2026, 3, 30)
    assert_includes dates, Date.new(2026, 4, 13)
    assert_not_includes dates, Date.new(2026, 3, 9)
  end

  test "weekly: empty days_of_week returns no dates" do
    recurrence = build_recurrence(frequency: "weekly", interval: 1, days_of_week: [])
    dates = calculate(recurrence, from: Date.new(2026, 3, 1), to: Date.new(2026, 4, 1))

    assert_empty dates
  end

  # -- Monthly (fixed day) --

  test "monthly: generates on fixed day of month" do
    recurrence = build_recurrence(frequency: "monthly", interval: 1, day_of_month: 15)
    dates = calculate(recurrence, from: Date.new(2026, 1, 1), to: Date.new(2026, 6, 30))

    expected = (1..6).map { |m| Date.new(2026, m, 15) }
    assert_equal expected, dates
  end

  test "monthly: every 2 months on the 10th" do
    recurrence = build_recurrence(frequency: "monthly", interval: 2, day_of_month: 10)
    dates = calculate(recurrence, from: Date.new(2026, 1, 1), to: Date.new(2026, 12, 31))

    assert_includes dates, Date.new(2026, 1, 10)
    assert_includes dates, Date.new(2026, 3, 10)
    assert_includes dates, Date.new(2026, 5, 10)
    assert_not_includes dates, Date.new(2026, 2, 10)
  end

  test "monthly: handles end-of-month overflow (day 31 in Feb)" do
    recurrence = build_recurrence(frequency: "monthly", interval: 1, day_of_month: 31)
    dates = calculate(recurrence, from: Date.new(2026, 1, 1), to: Date.new(2026, 4, 30))

    assert_includes dates, Date.new(2026, 1, 31)
    assert_includes dates, Date.new(2026, 2, 28)  # Feb 2026 has 28 days
    assert_includes dates, Date.new(2026, 3, 31)
    assert_includes dates, Date.new(2026, 4, 30)
  end

  # -- Monthly (Nth weekday) --

  test "monthly: first Saturday of the month" do
    recurrence = build_recurrence(
      frequency: "monthly", interval: 1,
      week_of_month: 1, day_of_week_monthly: 6
    )
    dates = calculate(recurrence, from: Date.new(2026, 1, 1), to: Date.new(2026, 6, 30))

    expected = [
      Date.new(2026, 1, 3),  # 1st Saturday of Jan
      Date.new(2026, 2, 7),  # 1st Saturday of Feb
      Date.new(2026, 3, 7),  # 1st Saturday of Mar
      Date.new(2026, 4, 4),  # 1st Saturday of Apr
      Date.new(2026, 5, 2),  # 1st Saturday of May
      Date.new(2026, 6, 6)   # 1st Saturday of Jun
    ]
    assert_equal expected, dates
  end

  test "monthly: third Wednesday of the month" do
    recurrence = build_recurrence(
      frequency: "monthly", interval: 1,
      week_of_month: 3, day_of_week_monthly: 3
    )
    dates = calculate(recurrence, from: Date.new(2026, 3, 1), to: Date.new(2026, 5, 31))

    expected = [
      Date.new(2026, 3, 18), # 3rd Wednesday of Mar
      Date.new(2026, 4, 15), # 3rd Wednesday of Apr
      Date.new(2026, 5, 20)  # 3rd Wednesday of May
    ]
    assert_equal expected, dates
  end

  test "monthly: 5th Friday may not exist in some months" do
    recurrence = build_recurrence(
      frequency: "monthly", interval: 1,
      week_of_month: 5, day_of_week_monthly: 5
    )
    # March 2026 has 5 Fridays (6, 13, 20, 27... wait, let's verify)
    # March 2026: starts on Sunday. Fridays: 6, 13, 20, 27 — only 4 Fridays
    # May 2026: starts on Friday. Fridays: 1, 8, 15, 22, 29 — 5 Fridays!
    dates = calculate(recurrence, from: Date.new(2026, 3, 1), to: Date.new(2026, 6, 30))

    assert_not_includes dates, Date.new(2026, 3, 1)  # No 5th Friday in March
    assert_includes dates, Date.new(2026, 5, 29)      # 5th Friday in May
  end

  # -- Yearly --

  test "yearly: generates on specific month and day" do
    recurrence = build_recurrence(
      frequency: "yearly", interval: 1,
      month_of_year: 7, day_of_month: 17
    )
    dates = calculate(recurrence, from: Date.new(2026, 1, 1), to: Date.new(2031, 12, 31))

    expected = (2026..2031).map { |y| Date.new(y, 7, 17) }
    assert_equal expected, dates
  end

  test "yearly: every 2 years" do
    recurrence = build_recurrence(
      frequency: "yearly", interval: 2,
      month_of_year: 12, day_of_month: 25
    )
    dates = calculate(recurrence, from: Date.new(2026, 1, 1), to: Date.new(2036, 12, 31))

    assert_includes dates, Date.new(2026, 12, 25)
    assert_includes dates, Date.new(2028, 12, 25)
    assert_not_includes dates, Date.new(2027, 12, 25)
  end

  test "yearly: handles Feb 29 in non-leap years" do
    recurrence = build_recurrence(
      frequency: "yearly", interval: 1,
      month_of_year: 2, day_of_month: 29
    )
    dates = calculate(recurrence, from: Date.new(2026, 1, 1), to: Date.new(2030, 12, 31))

    assert_includes dates, Date.new(2026, 2, 28)  # Non-leap → Feb 28
    assert_includes dates, Date.new(2028, 2, 29)  # Leap year → Feb 29
  end

  # -- Edge cases --

  test "from_date is exclusive, to_date is inclusive" do
    recurrence = build_recurrence(frequency: "daily", interval: 1)
    dates = calculate(recurrence, from: Date.new(2026, 3, 1), to: Date.new(2026, 3, 3))

    assert_not_includes dates, Date.new(2026, 3, 1)
    assert_includes dates, Date.new(2026, 3, 2)
    assert_includes dates, Date.new(2026, 3, 3)
  end

  private

  # @param attrs [Hash] attributes for EventRecurrence
  # @return [EventRecurrence] stubbed recurrence (not persisted)
  def build_recurrence(**attrs)
    EventRecurrence.new(
      frequency: attrs[:frequency] || "daily",
      interval: attrs[:interval] || 1,
      days_of_week: attrs[:days_of_week] || [],
      day_of_month: attrs[:day_of_month],
      week_of_month: attrs[:week_of_month],
      day_of_week_monthly: attrs[:day_of_week_monthly],
      month_of_year: attrs[:month_of_year],
      end_type: "never"
    )
  end

  # @param recurrence [EventRecurrence]
  # @param from [Date]
  # @param to [Date]
  # @return [Array<Date>]
  def calculate(recurrence, from:, to:)
    EventRecurrences::RecurrenceDateCalculator.new(
      recurrence: recurrence,
      from_date: from,
      to_date: to
    ).call
  end
end
