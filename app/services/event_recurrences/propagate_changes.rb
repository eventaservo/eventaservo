# frozen_string_literal: true

module EventRecurrences
  # Propagates changes from a master event to its future, non-detached child events.
  #
  # Updates selected fields, tags, organizations, and adjusts event times
  # when the master's start/end time-of-day has changed.
  #
  # @example
  #   EventRecurrences::PropagateChanges.call(master_event: event)
  class PropagateChanges < ApplicationService
    attr_reader :master_event

    # Fields that get propagated from master to children
    PROPAGATABLE_FIELDS = %w[
      title description city country_id address format site email
      time_zone specolisto latitude longitude online
    ].freeze

    # @param master_event [Event] the master event whose changes to propagate
    def initialize(master_event:)
      @master_event = master_event
    end

    # @return [ApplicationService::Response] success with count of updated events
    def call
      return failure("Event is not a recurring master") unless master_event.recurring_master?

      children = future_active_children
      updated_count = 0

      children.find_each do |child|
        update_fields(child)
        update_time_of_day(child)
        sync_tags(child)
        sync_organizations(child)
        updated_count += 1
      end

      success(updated_count)
    rescue => e
      failure(e.message)
    end

    private

    # @return [ActiveRecord::Relation]
    def future_active_children
      Event.active_in_series(master_event.id)
        .where("date_start >= ?", Time.current)
    end

    # @param child [Event]
    # @return [void]
    def update_fields(child)
      attrs = master_event.attributes.slice(*PROPAGATABLE_FIELDS)
      child.update!(attrs)
    end

    # Adjusts the child's start/end time-of-day to match the master's,
    # preserving the child's date and the original duration.
    #
    # @param child [Event]
    # @return [void]
    def update_time_of_day(child)
      tz = master_event.time_zone
      master_start = master_event.date_start.in_time_zone(tz)
      master_duration = master_event.date_end - master_event.date_start

      child_date = child.date_start.in_time_zone(tz).to_date
      new_start = ActiveSupport::TimeZone[tz].parse(
        "#{child_date} #{master_start.strftime("%H:%M:%S")}"
      )
      new_end = new_start + master_duration

      child.update_columns(date_start: new_start, date_end: new_end) # rubocop:disable Rails/SkipsModelValidations
    end

    # @param child [Event]
    # @return [void]
    def sync_tags(child)
      child.tags.clear
      master_event.tags.each { |tag| child.tags << tag }
    end

    # @param child [Event]
    # @return [void]
    def sync_organizations(child)
      child.organizations.clear
      master_event.organizations.each { |org| child.organizations << org }
    end
  end
end
