# frozen_string_literal: true

module Events
  # Calculates progress and day metrics for an event.
  #
  # Isolates the temporal calculation of total days, elapsed days,
  # remaining days, and percentage of time elapsed for an event.
  #
  # @example Calculate days progress for an event
  #   Events::DaysProgressCalculator.call(event)
  #   # => {total: 3, elapsed: 1, partial: 1, remaining: 2, percent: 33}
  #
  # @see Event
  class DaysProgressCalculator
    # Convenience class method to instantiate and run the calculator.
    #
    # @param event [Event] the event to calculate progress for
    #
    # @return [Hash{Symbol => Integer}] calculation results containing +:total+,
    #   +:elapsed+, +:partial+, +:remaining+, and +:percent+
    def self.call(event)
      new(event).call
    end

    # Initializes the calculator with the target event.
    #
    # @param event [Event] the event to calculate progress for
    def initialize(event)
      @event = event
    end

    # Computes and returns day metrics for the event.
    #
    # @return [Hash{Symbol => Integer}] calculation results containing +:total+,
    #   +:elapsed+, +:partial+, +:remaining+, and +:percent+
    def call
      total = calculate_total_days
      elapsed = calculate_elapsed_days
      remaining = total - elapsed
      percent = calculate_percent(elapsed, total)

      {
        total: total,
        elapsed: elapsed,
        partial: elapsed,
        remaining: remaining,
        percent: percent
      }
    end

    private

    attr_reader :event

    # Computes the total duration in days of the event.
    #
    # @return [Integer] total number of days
    def calculate_total_days
      (event.end_date_label.to_date - event.start_date_label.to_date).to_i + 1
    end

    # Computes the number of days that have elapsed relative to today in the event's timezone.
    #
    # @return [Integer] number of days elapsed
    def calculate_elapsed_days
      Time.use_zone(event.time_zone) do
        (Time.zone.today - event.start_date_label.to_date).to_i + 1
      end
    end

    # Computes the percentage of event duration that has elapsed.
    #
    # @param elapsed [Integer] days elapsed
    # @param total [Integer] total days
    #
    # @return [Integer] rounded integer percentage
    def calculate_percent(elapsed, total)
      return 0 if total.zero?

      ((elapsed.to_f / total.to_f) * 100).to_i
    end
  end
end
