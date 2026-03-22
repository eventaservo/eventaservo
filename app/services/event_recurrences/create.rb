# frozen_string_literal: true

module EventRecurrences
  # Creates a recurrence rule for an event and generates initial child events.
  #
  # Wraps the event in a transaction: creates the EventRecurrence record
  # and then calls GenerateChildren to produce the first batch.
  #
  # @example
  #   EventRecurrences::Create.call(
  #     event: event,
  #     recurrence_params: { frequency: "weekly", interval: 1, days_of_week: [2, 4] }
  #   )
  class Create < ApplicationService
    attr_reader :event, :recurrence_params

    # @param event [Event] the event to make recurring
    # @param recurrence_params [Hash] attributes for EventRecurrence
    def initialize(event:, recurrence_params:)
      @event = event
      @recurrence_params = recurrence_params
    end

    # @return [ApplicationService::Response] success with the recurrence, or failure
    def call
      return failure("Event is already a recurring master") if event.recurring_master?
      return failure("Event is a child of another series") if event.recurring_child?

      ActiveRecord::Base.transaction do
        recurrence = EventRecurrence.create!(
          recurrence_params.merge(master_event: event)
        )

        generation_result = GenerateChildren.call(recurrence:)

        if generation_result.success?
          success(recurrence)
        else
          raise ActiveRecord::Rollback, generation_result.error
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end
  end
end
