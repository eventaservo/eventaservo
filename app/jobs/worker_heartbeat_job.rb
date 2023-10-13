# frozen_string_literal: true

class WorkerHeartbeatJob < ApplicationJob
  queue_as :heartbeat
  retry_on SocketError, wait: 1.minute, attempts: 5

  def perform
    return if Rails.env.development?

    url = Rails.application.credentials.dig(:sentry, :worker_heartbeat_url)

    HTTParty.get("#{url}?environment=#{Rails.env}&status=ok")
  rescue
    HTTParty.get("#{url}?environment=#{Rails.env}&status=error")
  end
end
