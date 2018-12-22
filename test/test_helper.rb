# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

require 'codacy-coverage'
Codacy::Reporter.start

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Geocoder test configuration
  Geocoder.configure(lookup: :test, ip_lookup: :test)
  Geocoder::Lookup::Test.set_default_stub(
    [
      {
        coordinates: [40.7143528, -74.0059731],
        address: 'New York, NY, USA',
        state: 'New York',
        state_code: 'NY',
        country: 'United States',
        country_code: 'US'
      }
    ]
  )
end
