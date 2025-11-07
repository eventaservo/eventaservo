# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "debug"
require "simplecov"
require "simplecov-cobertura"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include FactoryBot::Syntax::Methods
  include ActionMailer::TestHelper

  # Timezone agordoj por provkodoj
  ::Timezone::Lookup.config(:test)
  ::Timezone::Lookup.lookup.stub(40.71, -74.00, "America/New_York")
  ::Timezone::Lookup.lookup.stub(-23.55, -46.63, "America/Sao_Paulo")
  ::Timezone::Lookup.lookup.stub(-7.11, -34.86, "America/Fortaleza")
  ::Timezone::Lookup.lookup.stub(43.66590881347656, -79.38521575927734, "America/Toronto")
  ::Timezone::Lookup.lookup.default("Etc/UTC")
end
