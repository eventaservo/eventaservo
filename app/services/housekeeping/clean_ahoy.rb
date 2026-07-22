# frozen_string_literal: true

module Housekeeping
  # Cleans old Ahoy analytics data to keep the database lean.
  #
  # Deletes ahoy_visits older than the retention period and
  # their orphaned ahoy_events, preserving the rollups table
  # which already contains aggregated historical metrics.
  #
  class CleanAhoy < ApplicationService
    # Number of days to retain raw Ahoy data.
    AHOV_VISITS_RETENTION_DAYS = 60

    # Number of records to delete per batch (avoids long locks).
    BATCH_SIZE = 1000

    # Cleans old Ahoy visits and orphaned events.
    #
    # @return [Hash] counts of deleted records
    def call
      {
        old_visits: clean_old_visits,
        orphaned_events: clean_orphaned_events,
        show_events: clean_old_show_event_events
      }
    end

    private

    # Deletes Ahoy visits older than +AHOV_VISITS_RETENTION_DAYS+.
    #
    # @return [Integer] total number of deleted visits
    def clean_old_visits
      Rails.logger.info "[Housekeeping] Deleting Ahoy visits older than #{AHOV_VISITS_RETENTION_DAYS} days..."

      total_deleted = 0
      cutoff = AHOV_VISITS_RETENTION_DAYS.days.ago

      loop do
        deleted = Ahoy::Visit
          .where("started_at < ?", cutoff)
          .limit(BATCH_SIZE)
          .delete_all

        break if deleted.zero?

        total_deleted += deleted
        Rails.logger.info "[Housekeeping] Deleted #{deleted} old Ahoy visits (total: #{total_deleted})"
      end

      Rails.logger.info "[Housekeeping] Finished deleting old Ahoy visits: #{total_deleted} removed"
      total_deleted
    end

    # Deletes orphaned Ahoy events whose parent visit no longer exists.
    #
    # @return [Integer] total number of deleted orphaned events
    def clean_orphaned_events
      Rails.logger.info "[Housekeeping] Deleting orphaned Ahoy events..."

      total_deleted = 0

      loop do
        deleted = Ahoy::Event
          .where.missing(:visit)
          .limit(BATCH_SIZE)
          .delete_all

        break if deleted.zero?

        total_deleted += deleted
        Rails.logger.info "[Housekeeping] Deleted #{deleted} orphaned Ahoy events (total: #{total_deleted})"
      end

      Rails.logger.info "[Housekeeping] Finished deleting orphaned Ahoy events: #{total_deleted} removed"
      total_deleted
    end

    # Cleans old "Show event" Ahoy events (existing behaviour).
    #
    # @return [Integer] number of deleted events
    def clean_old_show_event_events
      Rails.logger.info "[Housekeeping] Cleaning old 'Show event' Ahoy events..."

      deleted = Ahoy::Event.where(name: "Show event")
        .where("time < ?", 2.months.ago)
        .delete_all

      Rails.logger.info "[Housekeeping] Deleted #{deleted} old 'Show event' events"
      deleted
    end
  end
end
