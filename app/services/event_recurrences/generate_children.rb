# frozen_string_literal: true

module EventRecurrences
  # Generates child events based on a recurrence rule.
  #
  # Calculates upcoming dates within the generation horizon and creates
  # child events by cloning the master event attributes. Skips dates
  # that already have child events to avoid duplicates.
  #
  # @example
  #   EventRecurrences::GenerateChildren.call(recurrence: recurrence)
  class GenerateChildren < ApplicationService
    attr_reader :recurrence

    # Fields to copy from master to child events
    CLONED_FIELDS = %w[
      title description city country_id address format site email
      time_zone specolisto latitude longitude online display_flag
      user_id
    ].freeze

    # @param recurrence [EventRecurrence] the recurrence rule
    def initialize(recurrence:)
      @recurrence = recurrence
    end

    # @return [ApplicationService::Response] success with array of created events
    def call
      return failure("Recurrence is not active") unless recurrence.active?
      return failure("Recurrence should not generate more events") unless recurrence.should_generate_events?

      master = recurrence.master_event
      existing_future_count = master.recurrent_child_events
        .where("date_start >= ?", Time.current).count
      slots_available = recurrence.max_children - existing_future_count

      return success([]) if slots_available <= 0

      from_date = [
        recurrence.last_generated_date || master.date_start.to_date,
        Date.current - 1.day
      ].max
      to_date = recurrence.horizon_end_date

      return success([]) if from_date >= to_date

      dates = RecurrenceDateCalculator.new(
        recurrence: recurrence,
        from_date: from_date,
        to_date: to_date
      ).call

      created_events = []

      dates.each do |date|
        break if created_events.size >= slots_available

        next if child_exists_for_date?(master, date)

        event = create_child_event(master, date)
        created_events << event if event
      end

      recurrence.update!(last_generated_date: to_date)

      success(created_events)
    rescue => e
      failure(e.message)
    end

    private

    # @param master [Event]
    # @param date [Date]
    # @return [Boolean]
    def child_exists_for_date?(master, date)
      tz = ActiveSupport::TimeZone[master.time_zone]
      day_start = tz.parse("#{date} 00:00:00")
      day_end = tz.parse("#{date} 23:59:59")

      master.recurrent_child_events.exists?(date_start: day_start..day_end)
    end

    # @param master [Event]
    # @param date [Date]
    # @return [Event, nil]
    def create_child_event(master, date)
      duration = master.date_end - master.date_start
      start_time = build_start_time(master, date)
      end_time = start_time + duration

      child = Event.new(
        master_attributes(master).merge(
          recurrent_master_event_id: master.id,
          date_start: start_time,
          date_end: end_time
        )
      )

      # Suppress geocoding since we copy lat/lng
      child.define_singleton_method(:require_geocode?) { false }

      if child.save
        copy_associations(master, child)
        child
      else
        Rails.logger.error(
          "Failed to create recurring child event: #{child.errors.full_messages.join(", ")}"
        )
        nil
      end
    end

    # @param master [Event]
    # @return [Hash]
    def master_attributes(master)
      master.attributes.slice(*CLONED_FIELDS)
    end

    # @param master [Event]
    # @param date [Date]
    # @return [ActiveSupport::TimeWithZone]
    def build_start_time(master, date)
      time_of_day = master.date_start.in_time_zone(master.time_zone).strftime("%H:%M:%S")
      ActiveSupport::TimeZone[master.time_zone].parse("#{date} #{time_of_day}")
    end

    # @param master [Event]
    # @param child [Event]
    # @return [void]
    def copy_associations(master, child)
      master.tags.each do |tag|
        child.tags << tag unless child.tags.include?(tag)
      end

      master.organizations.each do |org|
        child.organizations << org unless child.organizations.include?(org)
      end
    end
  end
end
