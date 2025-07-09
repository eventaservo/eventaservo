require "constants"

Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn)
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set traces_sample_rate to 0.2 to capture 20%
  # of transactions for performance monitoring.
  # This provides sufficient data while keeping costs reasonable.
  config.traces_sample_rate = 0.2
  config.profiles_sample_rate = 0.2
  # or
  # config.traces_sampler = lambda do |_context|
  #   true
  # end

  config.enabled_environments = %w[production staging]
  config.enable_logs = true
end
