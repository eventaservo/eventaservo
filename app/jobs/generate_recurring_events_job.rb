# frozen_string_literal: true

# Daily job that advances the generation horizon for all active recurrences.
#
# Iterates over every active EventRecurrence and calls GenerateChildren
# to create any new child events within the rolling window.
# Errors are captured per-recurrence to avoid one failure blocking others.
class GenerateRecurringEventsJob < ApplicationJob
  queue_as :default

  # @return [void]
  def perform
    EventRecurrence.active.find_each do |recurrence|
      EventRecurrences::GenerateChildren.call(recurrence:)
    rescue => e
      Sentry.capture_exception(e, extra: {recurrence_id: recurrence.id})
    end
  end
end
