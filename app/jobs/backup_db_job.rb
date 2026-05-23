# frozen_string_literal: true

class BackupDbJob < ApplicationJob
  queue_as :low
  sentry_monitor_check_ins slug: "backup-db"

  # Executes a database backup and uploads it to Google Drive.
  #
  # @return [void]
  def perform
    Backup::Db.new.call
  end
end
