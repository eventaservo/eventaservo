# frozen_string_literal: true

class WorkerHeartbeatJob < ApplicationJob
  queue_as :heartbeat
  retry_on SocketError, wait: 1.minute, attempts: 5

  def perform
    return if Rails.env.development?

    better_uptime_heartbeat_url =
      if Rails.env.production?
        "https://betteruptime.com/api/v1/heartbeat/7TPghCQDGwxddtgDEDywD4QY"
      elsif Rails.env.staging?
        "https://betteruptime.com/api/v1/heartbeat/g9FjLQENgV1pxurjWUz6fFFf"
      end

    HTTParty.get(better_uptime_heartbeat_url)
  end
end
