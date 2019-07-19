# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'
# Use Puma as the app server
# gem 'puma', '~> 3.11'
gem 'puma', git: 'https://github.com/eric-norcross/puma.git', branch: 'chrome_70_ssl_curve_compatiblity'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

gem 'bootstrap', '>= 4.3.1'
gem 'font-awesome-sass', '~> 5'
gem 'haml', '~> 5'
gem 'jquery-rails', '~> 4.3', '>= 4.3.3'
gem 'jquery-ui-rails', '~> 6.0', '>= 6.0.1'
gem 'mini_racer'
gem 'select2-rails'

# Kalendaroj
gem 'fullcalendar-rails'
gem 'icalendar'
gem 'momentjs-rails'

gem 'devise', '~> 4.2'
gem 'mini_magick'
gem 'omniauth-facebook'
gem 'pg', '~> 1.1', '>= 1.1.3'
gem 'simple_token_authentication', '~> 1.0'
# gem 'rmagick'

# CSS kaj fasonado
gem 'flag-icons-rails'
gem 'social-share-button', git: 'https://github.com/shayani/social-share-button'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
gem 'yard'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'daemons'
gem 'delayed_job_active_record'

gem 'rack-attack'
gem 'rack-cors', require: 'rack/cors'

gem 'acts-as-taggable-on', '~> 6.0'
gem 'browser'
gem 'diffy'
gem 'geocoder'
gem 'highcharts-rails', '~> 6.0'
gem 'hirb'
gem 'impressionist'
gem 'invisible_captcha'
gem 'leaflet-rails'
gem 'pagy'
gem 'paper_trail'
gem 'paper_trail-association_tracking'
gem 'premailer-rails'
gem 'redcarpet'
gem 'redis'
gem 'sentry-raven'
gem 'sitemap_generator'
gem 'timezone', '~> 1.0'
gem 'trix-rails', require: 'trix'
gem 'httparty'
gem 'nokogiri'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'faker'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  # RailsPanel Chrome Extension
  gem 'meta_request'
  gem 'seed_dump' # Por rekrei la seeds.db dosieron

  # Capistrano gems
  gem 'bcrypt_pbkdf'
  gem 'capistrano', '~> 3.10', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-rvm', require: false
  gem 'ed25519'
end

group :test do
  gem 'capybara'
  # Codacy.com coverage
  gem 'codacy-coverage', require: false
  gem 'factory_bot_rails'
  gem 'minitest-reporters'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'webdrivers'
end
