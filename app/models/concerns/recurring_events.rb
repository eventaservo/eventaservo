# frozen_string_literal: true

# Concern for recurring events functionality on the Event model.
#
# Provides associations, scopes, and helper methods for managing
# parent-child relationships in recurring event series.
#
# @example Include in Event model
#   class Event < ApplicationRecord
#     include RecurringEvents
#   end
module RecurringEvents
  extend ActiveSupport::Concern

  included do
    # -- Associations --

    belongs_to :recurrent_master_event,
      class_name: "Event",
      optional: true

    has_many :recurrent_child_events,
      class_name: "Event",
      foreign_key: :recurrent_master_event_id,
      dependent: :nullify,
      inverse_of: :recurrent_master_event

    has_one :recurrence,
      class_name: "EventRecurrence",
      foreign_key: :master_event_id,
      dependent: :destroy,
      inverse_of: :master_event

    # -- Scopes --

    scope :recurring_masters, -> {
      joins(:recurrence)
    }

    scope :recurring_children, -> {
      where.not(recurrent_master_event_id: nil)
    }

    scope :standalone, -> {
      where(recurrent_master_event_id: nil)
        .where.missing(:recurrence)
    }

    scope :active_in_series, ->(master_id) {
      where(recurrent_master_event_id: master_id)
        .where(deleted: false)
        .where("metadata->>'detached_from_recurrent_series' IS NULL OR metadata->>'detached_from_recurrent_series' != ?", "true")
    }
  end

  # Checks if this event is a recurring master (has a recurrence rule)
  #
  # @return [Boolean]
  def recurring_master?
    recurrence.present?
  end

  # Checks if this event is a child in a recurring series
  #
  # @return [Boolean]
  def recurring_child?
    recurrent_master_event_id.present?
  end

  # Checks if this event is part of any recurring series
  #
  # @return [Boolean]
  def part_of_series?
    recurring_master? || recurring_child?
  end

  # Checks if this child event has been detached from its series
  #
  # @return [Boolean]
  def detached_from_recurrent_series?
    metadata&.dig("detached_from_recurrent_series") == true
  end

  # Detaches this child event from its recurrent series.
  # The event keeps its recurrent_master_event_id for historical reference
  # but is excluded from propagation and regeneration.
  #
  # @return [Boolean] true if successfully detached
  def detach_from_recurrent_series!
    self.metadata ||= {}
    self.metadata["detached_from_recurrent_series"] = true
    save!
  end

  # Returns the root event of the series
  #
  # @return [Event] the master event if child, or self if master
  def root_event
    recurring_child? ? recurrent_master_event : self
  end

  # Returns all events in the series (master + children), ordered by date
  #
  # @return [Array<Event>]
  def series_events
    if recurring_master?
      [self] + recurrent_child_events.order(:date_start)
    elsif recurring_child?
      recurrent_master_event.series_events
    else
      [self]
    end
  end

  # Returns upcoming events in the same series
  #
  # @param limit [Integer] maximum number of events to return
  # @return [ActiveRecord::Relation]
  def upcoming_events_in_series(limit: 5)
    root = root_event
    root.recurrent_child_events
      .where("date_start >= ?", Time.current)
      .order(:date_start)
      .limit(limit)
  end
end
