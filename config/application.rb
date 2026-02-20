require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Eventaservo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.time_zone = "UTC"

    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}")]
    config.i18n.available_locales = [:eo, :en, :pt_BR]
    config.i18n.default_locale = :eo

    config.exceptions_app = routes

    config.active_job.queue_adapter = :solid_queue
    config.active_storage.variant_processor = :mini_magick
    config.action_dispatch.default_headers = {"X-Frame-Options" => "ALLOWALL"}
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]
    config.active_record.schema_format = :sql

    config.eager_load_paths << Rails.root.join("test/mailers/previews")

    Dotenv::Rails.load if Rails.env.local?
  end
end
