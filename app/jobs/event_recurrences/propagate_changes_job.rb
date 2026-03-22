# frozen_string_literal: true

module EventRecurrences
  # Background job to propagate master event changes to future child events.
  #
  # Triggered when a recurring master event is updated, so the user
  # doesn't have to wait for propagation to complete.
  class PropagateChangesJob < ApplicationJob
    queue_as :default

    # @param event_id [Integer] the master event ID
    # @return [void]
    def perform(event_id)
      event = Event.find(event_id)
      return unless event.recurring_master?

      EventRecurrences::PropagateChanges.call(master_event: event)
    end
  end
end
