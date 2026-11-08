Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn)
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Capture 50% of transactions for performance monitoring. The organization
  # currently uses under 1% of its monthly performance quota, so there is ample
  # room to collect more traces while keeping a safety margin for traffic spikes.
  config.traces_sample_rate = 0.5
  config.profiles_sample_rate = 0.2
  # or
  # config.traces_sampler = lambda do |_context|
  #   true
  # end

  config.enabled_environments = %w[production staging]
  config.enable_logs = true

  if Rails.env.production?
    config.enable_logs = true
    config.enabled_patches = [:logger]
  end
end
