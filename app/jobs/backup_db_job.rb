# frozen_string_literal: true

class BackupDbJob < ApplicationJob
  queue_as :low

  def perform
    return if Rails.application.credentials.dig(:sentry, :backup_db_url).nil?

    trigger_sentry_cron("in_progress")

    Backup::Db.new.call

    trigger_sentry_cron("ok")
  rescue
    trigger_sentry_cron("error")
  end

  private

  def trigger_sentry_cron(status)
    sentry_url = Rails.application.credentials.dig(:sentry, :backup_db_url)
    HTTParty.get("#{sentry_url}?environment=#{Rails.env}&status=#{status}")
  end
end
