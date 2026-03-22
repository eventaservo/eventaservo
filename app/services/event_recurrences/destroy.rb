# frozen_string_literal: true

module EventRecurrences
  # Destroys a recurrence rule and optionally soft-deletes future child events.
  #
  # @example Destroy recurrence and keep future events
  #   EventRecurrences::Destroy.call(recurrence: recurrence, delete_future_events: false)
  #
  # @example Destroy recurrence and delete future events
  #   EventRecurrences::Destroy.call(recurrence: recurrence, delete_future_events: true)
  class Destroy < ApplicationService
    attr_reader :recurrence, :delete_future_events

    # @param recurrence [EventRecurrence] the recurrence to destroy
    # @param delete_future_events [Boolean] whether to soft-delete future child events
    def initialize(recurrence:, delete_future_events: true)
      @recurrence = recurrence
      @delete_future_events = delete_future_events
    end

    # @return [ApplicationService::Response]
    def call
      ActiveRecord::Base.transaction do
        delete_future_children if delete_future_events
        recurrence.destroy!

        success(recurrence.master_event)
      end
    rescue => e
      failure(e.message)
    end

    private

    # @return [void]
    def delete_future_children
      recurrence.master_event
        .recurrent_child_events
        .where("date_start >= ?", Time.current)
        .destroy_all
    end
  end
end
