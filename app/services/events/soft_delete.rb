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
        cleanup_recurrence_series if event.recurring_master?
        detach_from_series_if_child
        create_log

        success(event)
      else
        failure("Failed to soft delete event")
      end
    end

    private

    def user_can_delete_event?
      user.owner_of?(event) || user.organiza_membro_de_evento(event) || user.admin?
    end

    def set_deleted_attribute_to_true
      event.update(deleted: true)
    end

    # Permanently deletes future child events and destroys the recurrence rule
    # when the master event is soft-deleted.
    #
    # @return [void]
    def cleanup_recurrence_series
      event.recurrent_child_events
        .where("date_start >= ?", Time.current)
        .destroy_all

      event.recurrence&.destroy
    end

    # Detaches a child event from its recurring series before deletion
    # so the generation job does not recreate it.
    #
    # @return [void]
    def detach_from_series_if_child
      return unless event.recurring_child? && !event.detached_from_recurrent_series?

      event.detach_from_recurrent_series!
    end

    def create_log
      Logs::Create.call(text: "Event deleted", user:, loggable: event)
    end
  end
end
