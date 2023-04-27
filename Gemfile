# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.0.4"
# Use Puma as the app server
gem "puma", "~> 6"
# Use SCSS for stylesheets
gem "sass-rails", "~> 6"
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

gem "acts-as-taggable-on", "~> 9.0"

gem "bootstrap", "~> 4.3"
gem "font-awesome-sass", "~> 6"
gem "haml", "~> 5"
gem "jquery-rails", "~> 4.3", ">= 4.3.3"
gem "jquery-ui-rails", "~> 6.0", ">= 6.0.1"

gem "select2-rails", "~> 4.0"

# Kalendaroj
gem "fullcalendar-rails", "~> 3.9"
gem "icalendar", "~> 2.6"
gem "momentjs-rails", "~> 2.20"

gem "mini_magick", "~> 4.10"
gem "omniauth", "~> 1.9"
gem "omniauth-facebook", "~> 6.0"

# CSS kaj fasonado
gem "flag-icons-rails", "~> 3.4"

gem "devise", ">= 4.7.1"
gem "jwt", "~> 2.2"
gem "pg", "~> 1.1", ">= 1.1.3"
gem "simple_token_authentication", "~> 1.0"
gem "social-share-button"

# Use CoffeeScript for .coffee assets and views
gem "coffee-rails"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

gem "daemons", "~> 1.3"
gem "delayed_job_active_record", "~> 4.1"
gem "delayed_job_web"

gem "rack-attack", "~> 6.2"
gem "rack-cors", "~> 1.1", require: "rack/cors"

gem "activeadmin"
gem "browser", "~> 5.0"
gem "diffy", "~> 3.4"
gem "factory_bot_rails"
gem "faker"
gem "geocoder", "~> 1.6"
gem "highcharts-rails", "~> 6.0"
gem "hirb", "~> 0.7"
gem "image_processing", "~> 1.12"
gem "invisible_captcha", "~> 1.0"
gem "leaflet-rails", "~> 1.7.0"
gem "pagy", "~> 3.7.5"
gem "paper_trail", "~> 12.0"
gem "paper_trail-association_tracking", "~> 2.2"
gem "postmark-rails"
gem "premailer-rails", "~> 1.11"
gem "redcarpet", "~> 3.5"
gem "redis", "~> 4.1"
gem "sitemap_generator", "~> 6.1"
gem "timezone", "~> 1.0"
# gem 'trix-rails', require: 'trix'
gem "httparty", "~> 0.18"
gem "nokogiri", ">= 1.10.4"
gem "whenever", require: false
gem "yard"

# Hotwired
gem "stimulus-rails", "~> 1.2"
gem "turbo-rails", "~> 1.4"

# JS bundling
gem "jsbundling-rails", "~> 1.1"

# Sentry.io
gem "sentry-delayed_job", "~> 5"
gem "sentry-rails", "~> 5"
gem "sentry-ruby", "~> 5"

gem "listen"

# Bullet
# @TODO: must be moved to development but must be checked the docker build process to work fine
gem "bullet", "~> 7.0.3"

gem "ahoy_matey", "~> 4.1"

group :development, :test do
  gem "debug", ">= 1.0.0", require: false
  gem "dotenv-rails", "~> 2.8"
  gem "rake"
  gem "spring"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console"

  gem "annotate", "~> 3.2", require: false
  gem "better_errors"
  gem "binding_of_caller"
  gem "letter_opener_web", "~> 2.0"
  gem "pry-rails", "~> 0.3.4"
  gem "seed_dump" # Por rekrei la seeds.db dosieron
end

group :test do
  gem "capybara"
  gem "minitest", "~> 5.5"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  gem "standard", "~> 1", require: false
  gem "vcr"
  gem "webdrivers"
  gem "webmock"
end
