module Events
  module Recurring
    # Service to generate future events based on a recurrence rule
    #
    # This service calculates upcoming dates according to the recurrence pattern
    # and creates child events for each calculated date, copying attributes
    # from the parent event while maintaining the series relationship.
    class GenerateEvents < ApplicationService
      attr_reader :recurrence, :months_ahead, :master_event

      # Maximum number of events to generate per series to prevent runaway generation
      MAX_EVENTS_PER_SERIES = 5

      # Maximum months ahead to generate events for
      MAX_MONTHS_AHEAD = 24

      # @param recurrence [EventRecurrence] The recurrence rule to generate events for
      # @param months_ahead [Integer] Number of months ahead to generate (default: 6)
      def initialize(recurrence:, months_ahead: 6)
        @recurrence = recurrence
        @months_ahead = [months_ahead, MAX_MONTHS_AHEAD].min
        @master_event = recurrence.master_event
      end

      # Generates events based on the recurrence rule
      #
      # @return [ApplicationService::Response] Success with array of created events or failure
      def call
        return failure("Recurrence is not active") unless recurrence.active?
        # return failure("Recurrence should not generate more events") unless recurrence.should_generate_events?

        dates = calculate_next_dates
        events_created = create_events_for_dates(dates)

        success(events_created)
      rescue => e
        failure(e.message)
      end

      private

      # Calculates the next occurrence dates based on the recurrence pattern
      #
      # @return [Array<Date>] Array of dates for new events
      def calculate_next_dates
        calculator = RecurrenceDateCalculator.new(recurrence, months_ahead)
        calculator.next_dates
      end

      # Creates events for the calculated dates
      #
      # @param dates [Array<Date>] Dates to create events for
      # @return [Array<Event>] Array of created events
      def create_events_for_dates(dates)
        events = []

        dates.each do |date|
          next if event_exists_for_date?(date)

          event = create_child_event(date)
          events << event if event

          break if events.count >= MAX_EVENTS_PER_SERIES
        end

        events
      end

      # Checks if an event already exists for the given date
      #
      # @param date [Date] Date to check
      # @return [Boolean] true if event exists
      def event_exists_for_date?(date)
        master_event.child_events.exists?(date_start: date_range_for(date))
      end

      # Creates a date range for the given date to account for time zones
      #
      # @param date [Date] The date
      # @return [Range] Date range covering the entire day
      def date_range_for(date)
        date.beginning_of_day..date.end_of_day
      end

      # Creates a child event for the given date
      #
      # @param date [Date] Date for the new event
      # @return [Event, nil] Created event or nil if creation failed
      def create_child_event(date)
        duration = master_event.date_end - master_event.date_start

        child_params = build_child_params(date, duration)
        child_event = Event.new(child_params)

        if child_event.save
          copy_associations(child_event)
          child_event
        else
          Rails.logger.error "Failed to create child event: #{child_event.errors.full_messages.join(", ")}"
          nil
        end
      end

      # Builds parameters for the child event
      #
      # @param date [Date] Start date for the child event
      # @param duration [ActiveSupport::Duration] Duration of the event
      # @return [Hash] Parameters for creating the child event
      def build_child_params(date, duration)
        # Convert date to datetime in the parent event's timezone
        start_time = Time.zone.parse("#{date} #{master_event.komenca_horo}")
          .in_time_zone(master_event.time_zone)
        end_time = start_time + duration

        master_event.attributes.except(
          "id", "code", "created_at", "updated_at", "is_recurring_parent", "short_url"
        ).merge(
          master_event_id: master_event.id,
          date_start: start_time,
          date_end: end_time,
          is_recurring_parent: false
        )
      end

      # Copies associations from parent to child event
      #
      # @param child_event [Event] The child event to copy associations to
      def copy_associations(child_event)
        copy_tags(child_event)
        copy_organizations(child_event)
      end

      # Copies tags from parent to child event
      #
      # @param child_event [Event] The child event
      def copy_tags(child_event)
        master_event.tags.each do |tag|
          child_event.tags << tag unless child_event.tags.include?(tag)
        end
      end

      # Copies organizations from parent to child event
      #
      # @param child_event [Event] The child event
      def copy_organizations(child_event)
        master_event.organizations.each do |org|
          child_event.organizations << org unless child_event.organizations.include?(org)
        end
      end
    end

    # Helper class to calculate recurrence dates
    class RecurrenceDateCalculator
      def initialize(recurrence, months_ahead)
        @recurrence = recurrence
        @months_ahead = months_ahead
        @master_event = recurrence.master_event
      end
    end
  end
end
