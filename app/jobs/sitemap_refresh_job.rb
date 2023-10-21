# frozen_string_literal: true

class SitemapRefreshJob < ApplicationJob
  def perform
    return if Rails.env.development?

    trigger_sentry_cron("in_progress")

    Eventaservo::Application.load_tasks
    Rake::Task["sitemap:refresh"].invoke

    trigger_sentry_cron("ok")
  rescue
    trigger_sentry_cron("error")
  end

  private

  def trigger_sentry_cron(status)
    sentry_url = Rails.application.credentials.dig(:sentry, :sitemap_refresh_url)
    HTTParty.get("#{sentry_url}?environment=#{Rails.env}&status=#{status}")
  end
end
