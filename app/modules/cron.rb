# frozen_string_literal: true

module Cron
  def self.worker_heartbeat
    WorkerHeartbeatJob.perform_later
  end

  def self.sitemap_refresh
    SitemapRefreshJob.perform_later
  end
end
