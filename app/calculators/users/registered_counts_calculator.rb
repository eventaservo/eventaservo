# frozen_string_literal: true

module Users
  # Calculates the cumulative number of registered users at the end of each of
  # the last twelve months.
  #
  # The series is meant to be plotted as a growth chart: every entry counts all
  # the users registered up to that month end, so the values are cumulative
  # instead of per-month deltas.
  #
  # @example Twelve-month registration series
  #   Users::RegisteredCountsCalculator.new.call
  #   # => {months: ["Apr-25", "May-25", ..., "Mar-26"], counts: [120, 135, ..., 480]}
  #
  # @see User
  class RegisteredCountsCalculator
    # Returns the chart labels and the cumulative counts, oldest month first.
    #
    # The last entry always covers the current month end, so it matches the total
    # number of registered users as of today.
    #
    # @return [Hash{Symbol => Array}] +:months+ with the twelve month labels and
    #   +:counts+ with the cumulative user counts
    def call
      month_ends = last_12_month_ends

      {months: month_ends.map { |month_end| month_end.strftime("%b-%y") },
       counts: month_ends.map { |month_end| registered_users_until(month_end) }}
    end

    private

    # Returns the end-of-month dates for the last twelve months, oldest first.
    #
    # @note The thresholds are +Date+ values and therefore resolve to the midnight
    #   that opens the month end, which is the exact boundary the previous
    #   implementation used. Registrations made later on that last day are counted
    #   from the following month on; this class keeps that boundary on purpose, so
    #   the numbers the chart already showed do not change.
    #
    # @return [Array<Date>] end-of-month dates, from eleven months ago up to the current month
    def last_12_month_ends
      11.downto(0).map { |months_ago| (Time.zone.today - months_ago.months).end_of_month }
    end

    # Counts the users registered up to the given month end.
    #
    # @param month_end [Date] end-of-month threshold
    #
    # @return [Integer] cumulative number of registered users
    def registered_users_until(month_end)
      User.where("created_at <= ?", month_end).count
    end
  end
end
