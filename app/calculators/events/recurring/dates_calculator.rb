module Events
  module Recurring
    class DatesCalculator
      attr_reader :recurrence, :months_ahead, :master_event

      # @param recurrence [EventRecurrence] Recurrence
      # @param months_ahead [Integer] Months ahead
      def initialize(recurrence:, months_ahead:)
        @recurrence = recurrence
        @months_ahead = months_ahead
        @master_event = recurrence.master_event
      end

      # Calculates the next occurrence dates
      #
      # @return [Array<Date>] Array of calculated dates
      def next_dates
        case recurrence.frequency
        when "daily" then calculate_daily_dates
        when "weekly" then calculate_weekly_dates
        when "monthly" then calculate_monthly_dates
        else []
        end
      end

      private

      # Calculates daily recurrence dates
      #
      # @return [Array<Date>] Array of daily dates
      def calculate_daily_dates
        dates = []
        current_date = next_occurrence_date
        end_date = limit_end_date

        while current_date <= end_date && dates.count < Events::Recurring::GenerateEvents::MAX_EVENTS_PER_SERIES
          dates << current_date
          current_date += @recurrence.interval.days
        end

        dates
      end

      # Calculates weekly recurrence dates
      #
      # @return [Array<Date>] Array of weekly dates
      def calculate_weekly_dates
        dates = []
        current_date = next_occurrence_date
        end_date = limit_end_date

        while current_date <= end_date && dates.count < Events::Recurring::GenerateEvents::MAX_EVENTS_PER_SERIES
          if @recurrence.days_of_week.present?
            # Recurrence on specific days of the week
            week_start = current_date.beginning_of_week
            @recurrence.days_of_week.each do |day|
              date = week_start + day.days
              dates << date if date >= next_occurrence_date && date <= end_date
            end
          else
            # Recurrence on the same day of the week as the parent event
            dates << current_date
          end

          current_date += (@recurrence.interval * 7).days
        end

        dates.sort.uniq
      end

      # Calculates monthly recurrence dates
      #
      # @return [Array<Date>] Array of monthly dates
      def calculate_monthly_dates
        dates = []
        current_date = next_occurrence_date
        end_date = limit_end_date

        while current_date <= end_date && dates.count < Events::Recurring::GenerateEvents::MAX_EVENTS_PER_SERIES
          if @recurrence.day_of_month.present?
            # Specific day of the month
            target_day = [@recurrence.day_of_month, current_date.end_of_month.day].min
            date = Date.new(current_date.year, current_date.month, target_day)
          else
            # Same day of the month as the parent event
            target_day = [master_event.date_start.day, current_date.end_of_month.day].min
            date = Date.new(current_date.year, current_date.month, target_day)
          end

          dates << date if date >= next_occurrence_date
          current_date >>= @recurrence.interval # Next month
        end

        dates
      end

      # Gets the next occurrence date based on existing events
      #
      # @return [Date] Next occurrence date
      def next_occurrence_date
        @next_occurrence_date ||= begin
          last_generated = recurrence.generated_events.maximum(:date_start)&.to_date

          if last_generated
            calculate_next_from_date(last_generated)
          else
            # First generation - start from parent event date + interval
            calculate_next_from_date(master_event.date_start.to_date)
          end
        end
      end

      # Calculates next date from a given base date
      #
      # @param base_date [Date] Base date to calculate from
      # @return [Date] Next calculated date
      def calculate_next_from_date(base_date)
        case @recurrence.frequency
        when "daily"
          base_date + @recurrence.interval.days
        when "weekly"
          base_date + (@recurrence.interval * 7).days
        when "monthly"
          base_date >> @recurrence.interval
        when "yearly"
          base_date >> (12 * @recurrence.interval)
        else
          base_date + 1.day
        end
      end

      # Gets the limit end date for generation
      #
      # @return [Date] End date limit
      def limit_end_date
        @limit_end_date ||= begin
          max_date = Date.current + @months_ahead.months

          case @recurrence.end_type
          when "on_date"
            [@recurrence.end_date, max_date].min
          else
            max_date
          end
        end
      end
    end
  end
end
