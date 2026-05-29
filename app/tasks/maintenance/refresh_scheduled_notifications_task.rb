# frozen_string_literal: true

# Refreshes scheduled reminder notifications for all upcoming events.
#
# Iterates over all future events and reschedules their reminder jobs,
# ensuring each event has exactly one job per reminder interval
# (2h, 1w, 1m). Each event's existing old jobs are cleaned up
# individually by ScheduleReminders before new ones are created.
#
# Useful after fixing duplicate notification issues or after deploying
# changes to reminder scheduling logic.
#
# @example
#   Maintenance::RefreshScheduledNotificationsTask.run
module Maintenance
  class RefreshScheduledNotificationsTask < MaintenanceTasks::Task
    # Returns all future events to reschedule reminders for.
    #
    # @return [ActiveRecord::Relation<Event>]
    def collection
      Event.venontaj
    end

    # Reschedules reminder jobs for a single event.
    #
    # Deletes old enqueued jobs for the event and creates new ones.
    #
    # @param event [Event] the event to schedule reminders for
    # @return [void]
    def process(event)
      EventServices::ScheduleReminders.new(event).call
    end
  end
end
