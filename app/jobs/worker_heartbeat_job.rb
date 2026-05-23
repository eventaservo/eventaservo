# frozen_string_literal: true

class WorkerHeartbeatJob < ApplicationJob
  queue_as :low
  retry_on SocketError, wait: 1.minute, attempts: 5
  sentry_monitor_check_ins slug: "worker-heartbeat"

  # Sends heartbeat pings to Better Uptime to confirm the background
  # worker is alive. Sentry cron monitoring is handled automatically
  # by the +sentry_monitor_check_ins+ macro.
  #
  # @return [void]
  def perform
    return if Rails.env.development?

    better_uptime_url = Rails.application.credentials.dig(:better_uptime, :background_worker_heartbeat)
    HTTParty.get(better_uptime_url)
  end
end
