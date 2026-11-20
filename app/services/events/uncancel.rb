# frozen_string_literal: true

module Events
  # Service to uncancel a previously cancelled event.
  #
  # Verifies that the acting user is authorized to edit the event, clears the
  # cancellation flag and reason, and records an audit log entry.
  #
  # @example Uncancel an event
  #   Events::Uncancel.call(event: event, user: current_user)
  class Uncancel < ApplicationService
    attr_reader :event, :user

    # @param event [Event] the event to uncancel
    # @param user [User] the user performing the action
    def initialize(event:, user:)
      @event = event
      @user = user
    end

    # Executes the uncancellation logic.
    #
    # @return [ApplicationService::Response] success with Event payload, or failure with error message
    def call
      return failure("User is not authorized to uncancel event") unless EventPolicy.new(user:, event:).uncancel?

      if event.update(cancelled: false, cancel_reason: nil)
        Logs::Create.call(text: "Event uncancelled", user:, loggable: event)
        success(event)
      else
        failure(event.errors.messages)
      end
    end
  end
end
