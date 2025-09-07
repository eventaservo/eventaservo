# Concern for handling recurring events functionality
#
# This module provides all the logic needed for events to support recurrence,
# including associations, scopes, validations and helper methods.
#
# @example Include in Event model
#   class Event < ApplicationRecord
#     include RecurringEvents
#   end
module RecurringEvents
  extend ActiveSupport::Concern

  included do
    # Associations for recurring events
    belongs_to :master_event, class_name: "Event", optional: true
    has_many :child_events, class_name: "Event", foreign_key: "master_event_id", dependent: :destroy
    has_one :recurrence, class_name: "EventRecurrence", foreign_key: "master_event_id", dependent: :destroy

    # Scopes for recurring events
    scope :recurring_parents, -> { where(is_recurring_master: true) }
    scope :recurring_children, -> { where.not(master_event_id: nil) }
    scope :standalone_events, -> { where(master_event_id: nil, is_recurring_master: false) }
    scope :upcoming_in_series, ->(parent_id) {
      where(master_event_id: parent_id)
        .where("date_start >= ?", Time.current)
        .order(:date_start)
        .limit(10)
    }
    scope :recurring_series_with_next_events, -> {
      includes(:recurrence, child_events: [:country])
        .where(is_recurring_master: true)
    }

    # Validations for recurring events
    validate :master_event_cannot_be_recurring_child, if: :master_event_id?
    validate :recurring_parent_cannot_have_parent, if: :is_recurring_master?
  end

  # Instance methods for recurring events

  # Checks if this event is a recurring parent (has recurrence rule)
  #
  # @return [Boolean] true if this is a recurring parent event
  def recurring_parent?
    is_recurring_master?
  end

  # Checks if this event is a recurring child (part of a series)
  #
  # @return [Boolean] true if this is a child event in a recurring series
  def recurring_child?
    master_event_id.present?
  end

  # Checks if this event is part of any recurring series
  #
  # @return [Boolean] true if this event is either a parent or child in a series
  def part_of_series?
    recurring_parent? || recurring_child?
  end

  # Returns the root event of the series
  #
  # @return [Event] the parent event if this is a child, or self if this is the parent
  def root_event
    recurring_child? ? master_event : self
  end

  # Returns the series this event belongs to
  #
  # @return [Array<Event>] all events in the same series (including parent)
  def series_events
    if recurring_parent?
      [self] + child_events.order(:date_start)
    elsif recurring_child?
      master_event.series_events
    else
      [self]
    end
  end

  # Returns upcoming events in the same series
  #
  # @param limit [Integer] maximum number of events to return
  # @return [ActiveRecord::Relation] upcoming events in the series
  def upcoming_events_in_series(limit: 5)
    root_event.child_events
      .where("date_start >= ?", Time.current)
      .order(:date_start)
      .limit(limit)
  end

  # Returns past events in the same series
  #
  # @param limit [Integer] maximum number of events to return
  # @return [ActiveRecord::Relation] past events in the series
  def past_events_in_series(limit: 5)
    root_event.child_events
      .where("date_start < ?", Time.current)
      .order(date_start: :desc)
      .limit(limit)
  end

  # Checks if this event can be edited as part of a series
  #
  # @param user [User] the user trying to edit
  # @return [Boolean] true if user can edit this event series
  def can_edit_series?(user)
    return false unless user
    return true if user.admin?

    root_event.user == user || root_event.organizations.any? { |org| org.users.include?(user) }
  end

  # Returns a description of the recurrence pattern
  #
  # @return [String, nil] description of recurrence or nil if not recurring
  def recurrence_description
    return nil unless recurring_parent? && recurrence

    recurrence.description
  end

  # Checks if the series should continue generating events
  #
  # @return [Boolean] true if more events should be generated
  def should_generate_more_events?
    return false unless recurring_parent? && recurrence

    recurrence.should_generate_events?
  end

  # Returns the next occurrence date for this series
  #
  # @return [Date, nil] next occurrence date or nil if series is complete
  def next_occurrence_date
    return nil unless recurring_parent? && recurrence

    recurrence.next_occurrence_date
  end

  # Counts total events in the series (including parent)
  #
  # @return [Integer] total number of events in the series
  def series_count
    if recurring_parent?
      1 + child_events.count
    elsif recurring_child?
      master_event.series_count
    else
      1
    end
  end

  # Checks if this is the first event in a series
  #
  # @return [Boolean] true if this is the first event
  def first_in_series?
    if recurring_parent?
      true
    elsif recurring_child?
      master_event.date_start >= date_start
    else
      true
    end
  end

  # Checks if this is the last event in a series
  #
  # @return [Boolean] true if this is the last event
  def last_in_series?
    if recurring_parent?
      child_events.empty? || !should_generate_more_events?
    elsif recurring_child?
      siblings = master_event.child_events.order(:date_start)
      siblings.last == self && !master_event.should_generate_more_events?
    else
      true
    end
  end

  # Returns the position of this event in the series
  #
  # @return [Integer] position in series (1-based)
  def position_in_series
    if recurring_parent?
      1
    elsif recurring_child?
      master_event.child_events.where("date_start <= ?", date_start).count + 1
    else
      1
    end
  end

  # Creates a copy of this event for the next occurrence
  #
  # @param new_date_start [DateTime] start date for the new event
  # @return [Event] new event instance (not saved)
  def build_next_occurrence(new_date_start)
    return nil unless recurring_parent?

    duration = date_end - date_start
    new_date_end = new_date_start + duration

    attributes_to_copy = attributes.except(
      "id", "code", "created_at", "updated_at", "is_recurring_master", "short_url"
    )

    child_event = self.class.new(attributes_to_copy.merge(
      master_event_id: id,
      date_start: new_date_start,
      date_end: new_date_end,
      is_recurring_master: false
    ))

    # Copy associations after saving
    child_event.define_singleton_method(:copy_associations_from_parent) do
      # Copy tags
      master_event.tags.each do |tag|
        tags << tag unless tags.include?(tag)
      end

      # Copy organizations
      master_event.organizations.each do |org|
        organizations << org unless organizations.include?(org)
      end
    end

    child_event
  end

  # Cache method for upcoming events in series to improve performance
  #
  # @return [Array<Event>] cached upcoming events in the series
  def upcoming_events_cached
    return [] unless recurring_parent?

    Rails.cache.fetch("event_#{id}_upcoming_events", expires_in: 1.hour) do
      upcoming_events_in_series.includes(:country).to_a
    end
  end

  private

  # Custom validations

  def master_event_cannot_be_recurring_child
    return unless master_event

    if master_event.master_event_id.present?
      errors.add(:master_event, "cannot be a child event from another series")
    end
  end

  def recurring_parent_cannot_have_parent
    if master_event_id.present?
      errors.add(:base, "recurring parent events cannot have a parent event")
    end
  end
end
