# frozen_string_literal: true
require "constants"

Sentry.init do |config|
  config.dsn = 'https://6b22c73cdd694a8b90f6b1d84ffa51df@o199541.ingest.sentry.io/1309834'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  config.sample_rate = 1.0
  config.traces_sample_rate = 0.5
  config.release = Constants::VERSIO
  config.enabled_environments = %w[prodution staging]
  # config.async = lambda do |event, hint|
  #   Sentry::SendEventJob.perform_later(event, hint)
  # end
end
