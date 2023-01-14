require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.after_initialize do
    Bullet.enable        = true
    Bullet.rails_logger  = true
  end

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries    = true

  config.action_mailer.delivery_method = :smtp

  # Mailcatcher
  config.action_mailer.smtp_settings = {
    address: (ENV["MAILCATCHER_HOST"] || "localhost"),
    port: "1025"
  }

  # Gmail
  # config.action_mailer.smtp_settings = {
  # address:              "smtp.gmail.com",
  # port:                 "587",
  # domain:               "gmail.com",
  # user_name:            Rails.application.credentials.dig(:email, :development, :username),
  # password:             Rails.application.credentials.dig(:email, :development, :password),
  # authentication:       "plain",
  # enable_starttls_auto: true
  # }

  config.action_mailer.perform_caching = false

  config.action_mailer.default_url_options = { host: "localhost", port: 3000, protocol: "https" }
  default_url_options = { host: "localhost", port: 3000, protocol: "https" }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  # config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.force_ssl = false
  config.hosts << "3000-eventaservo-eventaservo-lbisapj41jr.ws-us46.gitpod.io"
  config.hosts << "*.gitpod.io"
  config.hosts << "devel.eventaservo.org"
  config.active_job.default_url_options = { host: "localhost", port: 3000, protocol: :https }
  Rails.application.routes.default_url_options[:host] = "localhost"
  Rails.application.routes.default_url_options[:port] = 3000
  Rails.application.routes.default_url_options[:protocol] = :https
end
