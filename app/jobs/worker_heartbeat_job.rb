# frozen_string_literal: true

class WorkerHeartbeatJob < ApplicationJob
  queue_as :low
  retry_on SocketError, wait: 1.minute, attempts: 5

  def perform
    return if Rails.env.development?

    sentry_url = Rails.application.credentials.dig(:sentry, :worker_heartbeat_url)
    HTTParty.get("#{sentry_url}?environment=#{Rails.env}&status=ok")

    better_uptime_url = Rails.application.credentials.dig(:better_uptime, :background_worker_heartbeat)
    HTTParty.get(better_uptime_url)
  end
end
