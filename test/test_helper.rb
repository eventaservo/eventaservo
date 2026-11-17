# frozen_string_literal: true

if ENV["CI"]
  require "simplecov"
  require "simplecov-cobertura"

  SimpleCov.start "rails" do
    skip "/test/"
    skip "/config/"
    # Keep every worker's resultset entry mergeable when the parent collates them.
    merge_timeout 3600
    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::CoberturaFormatter
    ])
  end
end

ENV["RAILS_ENV"] = "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "minitest/mock"
require "debug"
require "geocoder"
require_relative "support/geocoder_stub"
require_relative "support/timezone_stub"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)

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
