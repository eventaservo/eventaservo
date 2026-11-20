# frozen_string_literal: true

module Events
  # Service to cancel an event with an optional cancellation reason.
  #
  # Verifies that the acting user is authorized to edit the event, marks the
  # event as cancelled, and records an audit log entry.
  #
  # @example Cancel an event
  #   Events::Cancel.call(event: event, user: current_user, cancel_reason: "Weather")
  class Cancel < ApplicationService
    attr_reader :event, :user, :cancel_reason

    # @param event [Event] the event to cancel
    # @param user [User] the user performing the cancellation
    # @param cancel_reason [String, nil] optional reason explaining why the event was cancelled
    def initialize(event:, user:, cancel_reason: nil)
      @event = event
      @user = user
      @cancel_reason = cancel_reason
    end

    # Executes the cancellation logic.
    #
    # @return [ApplicationService::Response] success with Event payload, or failure with error message
    def call
      return failure("User is not authorized to cancel event") unless EventPolicy.new(user:, event:).cancel?

      if event.update(cancelled: true, cancel_reason:)
        Logs::Create.call(text: "Event cancelled", user:, loggable: event)
        success(event)
      else
        failure(event.errors.messages)
      end
    end
  end
end
