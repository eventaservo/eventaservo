# frozen_string_literal: true

require "simplecov"
require "simplecov-cobertura"

SimpleCov.start "rails" do
  add_filter "/test/"
  add_filter "/config/"
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::CoberturaFormatter
  ])
end

ENV["RAILS_ENV"] = "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "debug"
require "geocoder"
require_relative "support/geocoder_stub"
require_relative "support/timezone_stub"

class ActiveSupport::TestCase
  # Parallelization disabled on macOS due to fork() incompatibility with PostgreSQL/GSS
  # On Linux (CI), processes work fine. On macOS, fork() crashes with "multi-threaded process forked"
  # See: https://github.com/rails/rails/issues/31991
  if !RUBY_PLATFORM.include?("darwin")
    parallelize(workers: :number_of_processors)
  end

  fixtures :all
  include FactoryBot::Syntax::Methods
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper
  include Devise::Test::IntegrationHelpers
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
