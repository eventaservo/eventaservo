# frozen_string_literal: true

module EventRecurrences
  # Calculates occurrence dates for a given recurrence pattern.
  #
  # Supports daily, weekly (specific days), monthly (fixed day or Nth weekday),
  # and yearly recurrence patterns with configurable intervals.
  #
  # @example Calculate next dates for a weekly recurrence
  #   calculator = RecurrenceDateCalculator.new(
  #     recurrence: recurrence,
  #     from_date: Date.current,
  #     to_date: Date.current + 6.weeks
  #   )
  #   calculator.call # => [Date, Date, ...]
  class RecurrenceDateCalculator
    attr_reader :recurrence, :from_date, :to_date

    # @param recurrence [EventRecurrence] the recurrence rule
    # @param from_date [Date] start of the calculation window (exclusive)
    # @param to_date [Date] end of the calculation window (inclusive)
    def initialize(recurrence:, from_date:, to_date:)
      @recurrence = recurrence
      @from_date = from_date
      @to_date = to_date
    end

    # Calculates all occurrence dates within the window
    #
    # @return [Array<Date>] sorted array of dates
    def call
      dates = case recurrence.frequency
      when "daily" then calculate_daily
      when "weekly" then calculate_weekly
      when "monthly" then calculate_monthly
      when "yearly" then calculate_yearly
      else []
      end

      dates.select { |d| d > from_date && d <= to_date }.sort
    end

    private

    # @return [Array<Date>]
    def calculate_daily
      dates = []
      current = from_date + recurrence.interval.days

      while current <= to_date
        dates << current
        current += recurrence.interval.days
      end

      dates
    end

    # @return [Array<Date>]
    def calculate_weekly
      dates = []
      target_days = recurrence.days_of_week || []
      return dates if target_days.empty?

      # Start from the beginning of the week containing from_date
      week_start = from_date.beginning_of_week(:sunday)
      current_week = week_start

      while current_week <= to_date
        target_days.each do |wday|
          candidate = current_week + wday.days
          dates << candidate if candidate > from_date && candidate <= to_date
        end

        current_week += (recurrence.interval * 7).days
      end

      dates
    end

    # @return [Array<Date>]
    def calculate_monthly
      if recurrence.week_of_month.present? && recurrence.day_of_week_monthly.present?
        calculate_monthly_nth_weekday
      else
        calculate_monthly_fixed_day
      end
    end

    # @return [Array<Date>]
    def calculate_monthly_fixed_day
      dates = []
      day = recurrence.day_of_month
      current_month = from_date.beginning_of_month

      while current_month <= to_date
        candidate = safe_date(current_month.year, current_month.month, day)
        dates << candidate if candidate && candidate > from_date && candidate <= to_date

        current_month >>= recurrence.interval
      end

      dates
    end

    # @return [Array<Date>]
    def calculate_monthly_nth_weekday
      dates = []
      nth = recurrence.week_of_month
      target_wday = recurrence.day_of_week_monthly
      current_month = from_date.beginning_of_month

      while current_month <= to_date
        candidate = nth_weekday_of_month(current_month.year, current_month.month, nth, target_wday)
        dates << candidate if candidate && candidate > from_date && candidate <= to_date

        current_month >>= recurrence.interval
      end

      dates
    end

    # @return [Array<Date>]
    def calculate_yearly
      dates = []
      month = recurrence.month_of_year
      day = recurrence.day_of_month
      current_year = from_date.year

      while Date.new(current_year, 1, 1) <= to_date
        candidate = safe_date(current_year, month, day)
        dates << candidate if candidate && candidate > from_date && candidate <= to_date

        current_year += recurrence.interval
      end

      dates
    end

    # Safely builds a Date, handling end-of-month overflow (e.g. Feb 30 → Feb 28/29)
    #
    # @param year [Integer]
    # @param month [Integer]
    # @param day [Integer]
    # @return [Date, nil]
    def safe_date(year, month, day)
      last_day = Date.new(year, month, -1).day
      Date.new(year, month, [day, last_day].min)
    rescue ArgumentError
      nil
    end

    # Finds the Nth occurrence of a weekday in a given month
    #
    # @param year [Integer]
    # @param month [Integer]
    # @param nth [Integer] 1-based (1 = first, 2 = second, etc.)
    # @param target_wday [Integer] 0 = Sunday, 6 = Saturday
    # @return [Date, nil] the date, or nil if it doesn't exist (e.g. 5th Saturday)
    def nth_weekday_of_month(year, month, nth, target_wday)
      first_day = Date.new(year, month, 1)
      last_day = Date.new(year, month, -1)

      # Find all occurrences of target_wday in this month
      current = first_day + ((target_wday - first_day.wday) % 7)
      occurrences = []

      while current <= last_day
        occurrences << current
        current += 7
      end

      occurrences[nth - 1]
    rescue ArgumentError
      nil
    end
  end
end
