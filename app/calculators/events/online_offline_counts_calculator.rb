# frozen_string_literal: true

module Events
  # Builds the monthly online and offline event count series for the last
  # twelve months.
  #
  # Each month of the window is reported as two counts: the number of online
  # events created during that month and the number of non-online (physical)
  # events. The result is a chart-ready hash with one series per event format
  # and a shared x-axis of month labels.
  #
  # @example Twelve-month online/offline series
  #   Events::OnlineOfflineCountsCalculator.new.call
  #   # => {events: [{name: "Physical", data: [...]}, {name: "Online", data: [...]}],
  #   #      x_axis: ["Apr-25", ..., "Mar-26"]}
  #
  # @see Event
  class OnlineOfflineCountsCalculator
    # Returns the online and offline event count series over the last twelve
    # months, oldest month first.
    #
    # @return [Hash{Symbol => Array}] +:events+ with one entry per event format
    #   (+name+ label and +data+ counts, physical first, online second) and
    #   +:x_axis+ with the twelve month labels
    def call
      month_starts = last_12_months
      online_data = month_starts.map { |start| online_events_created(start) }
      offline_data = month_starts.map { |start| offline_events_created(start) }

      {
        events: [
          {name: "Physical", data: offline_data},
          {name: "Online", data: online_data}
        ],
        x_axis: last_12_months_label
      }
    end

    private

    # Returns the first day of each of the last twelve months, oldest first.
    #
    # @return [Array<Date>] first day of each month, from eleven months ago up to the current month
    def last_12_months
      11.downto(0).map { |months_ago| Date.today - months_ago.months }
    end

    # Counts the online events created during the given month.
    #
    # @param month_start [Date] first day of the month window
    #
    # @return [Integer] number of online events
    def online_events_created(month_start)
      Event.online.where(created_at: month_start.all_month).count
    end

    # Counts the non-online (physical) events created during the given month.
    #
    # @param month_start [Date] first day of the month window
    #
    # @return [Integer] number of non-online (physical) events
    def offline_events_created(month_start)
      Event.not_online.where(created_at: month_start.all_month).count
    end

    # Returns the end-of-month labels for the last twelve months, oldest first.
    #
    # @return [Array<String>] month labels such as "Apr-25"
    def last_12_months_label
      11.downto(0).map do |months_ago|
        (Time.zone.today - months_ago.months).end_of_month.strftime("%b-%y")
      end
    end
  end
end
