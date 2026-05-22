# frozen_string_literal: true

# Normalizes legacy IANA timezone identifiers across all events.
#
# Maps deprecated identifiers (e.g., "America/Buenos_Aires", "Asia/Calcutta")
# to their canonical forms recognized by ActiveSupport::TimeZone.
#
# @example
#   Maintenance::NormalizeEventTimezonesTask.process(event)
module Maintenance
  class NormalizeEventTimezonesTask < MaintenanceTasks::Task
    # Returns all events in the database.
    #
    # @return [ActiveRecord::Relation<Event>]
    def collection
      Event.unscoped
    end

    # Normalizes a single event's timezone if it is a legacy identifier.
    #
    # - On service failure: logs an error, preserves the original value.
    # - On success with a different timezone: updates the record, logs info.
    # - On success with no change needed: does nothing.
    #
    # @param event [Event] the event to process
    # @return [void]
    def process(event)
      original = event.time_zone
      result = TimeZone::Normalize.call(original)

      unless result.success?
        Rails.logger.error "Timezone normalization failed for event ##{event.id}: #{original}"
        return
      end

      normalized = result.payload
      return if normalized == original

      event.update_column(:time_zone, normalized)
      Rails.logger.info "Timezone normalized for event ##{event.id}: #{original} -> #{normalized}"
    end
  end
end
