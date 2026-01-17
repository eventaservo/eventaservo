# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.4.7"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.2.2.2"
# Use Puma as the app server
gem "puma", "~> 7"
gem "thruster", "~> 0.1.7"

# Use SCSS for stylesheets
gem "sass-rails", "~> 6"
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

gem "bootsnap", require: false
gem "bootstrap", "~> 4.3"
gem "font-awesome-sass", "~> 6"
gem "jquery-rails", "~> 4.3", ">= 4.3.3"
gem "jquery-ui-rails", "~> 8.0"

# Kalendaroj
gem "fullcalendar-rails", "~> 3.9"
gem "icalendar", "~> 2.6"
gem "momentjs-rails", "~> 2.20"

gem "mini_magick", "~> 4.10"

# Omniauth authentication
gem "omniauth-facebook", "~> 9.0"
gem "omniauth-google-oauth2", "~> 1.2"
gem "omniauth-rails_csrf_protection"

# CSS kaj fasonado
gem "flag-icons-rails", "~> 3.4"

gem "devise", ">= 4.7.1"
gem "jwt", "~> 2.2"
gem "pg", "~> 1.1", ">= 1.1.3"
gem "simple_token_authentication", "~> 1.0"
gem "social-share-button"

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.14"
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

gem "rack-attack", "~> 6.2"
gem "rack-cors", "~> 3.0", require: "rack/cors"

gem "activeadmin", "~> 3"
gem "aws-sdk-s3", "~> 1.197"
gem "browser", "~> 6"
gem "chartkick", "~> 5.0"
gem "diffy", "~> 3.4"
gem "geocoder", "~> 1.6"
gem "groupdate", "~> 6.4"
gem "highcharts-rails", "~> 6.0"
gem "image_processing", ">= 1.2"
gem "pagy", "~> 7.0"
gem "paper_trail", "~> 15.1"
gem "paper_trail-association_tracking", "~> 2.2"
gem "postmark-rails"
gem "premailer-rails", "~> 1.11"
gem "redcarpet", "~> 3.5"
gem "sitemap_generator", "~> 6.1"
gem "timezone", "~> 1.0"
gem "view_component", "~> 3.10"
# gem 'trix-rails', require: 'trix'
gem "httparty", "~> 0.18"
gem "nokogiri", ">= 1.10.4"
gem "yard"

# Hotwired
gem "stimulus-rails", "~> 1.2"
gem "turbo-rails", "~> 2"
gem "hotwire_combobox", "~> 0.3.1"

# Bundling gems
gem "jsbundling-rails", "~> 1.1"
gem "cssbundling-rails", "~> 1.4"

# Solid Queue
gem "solid_queue", "~> 1.2.1"
gem "mission_control-jobs"

# Sentry.io
gem "stackprof"
gem "sentry-ruby", "~> 6"
gem "sentry-rails", "~> 6"

gem "listen"

# Bullet
# @TODO: must be moved to development but must be checked the docker build process to work fine
gem "bullet", "~> 8"

# For statistics
gem "ahoy_matey", "~> 5"
gem "rollups", "~> 0.3.2"

# For localization
# https://lokalise.com
gem "lokalise_rails", "~> 7.0"

# For connecting to Google Drive
gem "google-api-client", "~> 0.53.0"

group :development, :test do
  gem "debug", ">= 1.0.0", require: false
  gem "dotenv-rails"
  gem "faker"
  gem "lookbook", ">= 2.3.4"
  gem "parallel_tests"
  gem "rake"
  gem "rspec-rails"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  # gem "web-console", group: :development

  gem "annotaterb", require: false
  gem "better_errors"
  gem "binding_of_caller"
  gem "htmlbeautifier", "~> 1.4"
  gem "letter_opener_web", "~> 3"
  gem "pry-rails", "~> 0.3.4"
  gem "seed_dump" # Por rekrei la seeds.db dosieron
  gem "standard"
end

group :test do
  gem "capybara"
  gem "factory_bot_rails"
  gem "minitest", "~> 5.5"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "simplecov-cobertura"
  gem "vcr"
  gem "webmock"
end
