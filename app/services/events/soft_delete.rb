# frozen_string_literal: true

module Events
  class SoftDelete < ApplicationService
    attr_reader :event, :user

    # @param event [Event] The event to be deleted
    # @param user [User] The user who is deleting the event
    def initialize(event:, user:)
      @event = event
      @user = user
    end

    def call
      return failure("User is not authorized to delete event") unless user_can_delete_event?

      if set_deleted_attribute_to_true
        create_log

        success(event)
      else
        failure("Failed to soft delete event")
      end
    end

    private

    # Checks whether the user is authorized to delete the event.
    #
    # @return [Boolean]
    def user_can_delete_event?
      user.can_edit_event?(event)
    end

    def set_deleted_attribute_to_true
      event.update(deleted: true)
    end

    def create_log
      Logs::Create.call(text: "Event deleted", user:, loggable: event)
    end
  end
end
