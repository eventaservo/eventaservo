# frozen_string_literal: true

# Refreshes scheduled reminder notifications for all upcoming events.
#
# Purges any existing pending event_reminder jobs and recreates them,
# ensuring each future event has exactly one job per reminder interval
# (2h, 1w, 1m). Useful after fixing duplicate notification issues or
# after deploying changes to reminder scheduling logic.
#
# @example
#   Maintenance::RefreshScheduledNotificationsTask.run
module Maintenance
  class RefreshScheduledNotificationsTask < MaintenanceTasks::Task
    # Returns all future events to reschedule reminders for.
    #
    # Before iterating, purges any existing pending event_reminder jobs
    # to ensure a clean slate.
    #
    # @return [ActiveRecord::Relation<Event>]
    def collection
      SolidQueue::Job.where(queue_name: "event_reminders", finished_at: nil).destroy_all
      Event.venontaj
    end

    # Reschedules reminder jobs for a single event.
    #
    # @param event [Event] the event to schedule reminders for
    # @return [void]
    def process(event)
      EventServices::ScheduleReminders.new(event).call
    end
  end
end
