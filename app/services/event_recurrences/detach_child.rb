# frozen_string_literal: true

module EventRecurrences
  # Detaches a child event from its recurring series.
  #
  # The event keeps its recurrent_master_event_id for historical reference
  # but is excluded from future propagation and regeneration checks
  # via the metadata flag.
  #
  # @example
  #   EventRecurrences::DetachChild.call(event: child_event)
  class DetachChild < ApplicationService
    attr_reader :event

    # @param event [Event] the child event to detach
    def initialize(event:)
      @event = event
    end

    # @return [ApplicationService::Response]
    def call
      return failure("Event is not a recurring child") unless event.recurring_child?
      return failure("Event is already detached") if event.detached_from_recurrent_series?

      event.detach_from_recurrent_series!
      success(event)
    rescue => e
      failure(e.message)
    end
  end
end
