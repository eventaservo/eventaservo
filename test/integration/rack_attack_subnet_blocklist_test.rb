# frozen_string_literal: true

require "test_helper"

# Covers the subnet blocklist in config/initializers/rack_attack.rb so
# distributed cloud scraper ranges receive 403 Forbidden while normal visitor
# and localhost traffic continue to pass through.
class RackAttackSubnetBlocklistTest < ActionDispatch::IntegrationTest
  BLOCKED_SAMPLE_IPS = %w[
    47.79.11.211
    47.82.49.46
    47.84.61.18
    47.238.246.62
    43.135.20.213
  ].freeze

  setup do
    @previous_store = Rack::Attack.cache.store
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rack::Attack.cache.store = @previous_store
  end

  test "blocks requests originating from configured scraper subnets" do
    BLOCKED_SAMPLE_IPS.each do |ip|
      get "/", headers: {"CF-Connecting-IP" => ip}
      assert_response :forbidden, "Expected #{ip} to be blocked with 403"
    end
  end

  test "blocks requests from scraper subnets resolved via X-Forwarded-For" do
    get "/", headers: {"X-Forwarded-For" => "47.82.53.51"}
    assert_response :forbidden
  end

  test "allows requests from normal visitor IPs outside blocked subnets" do
    %w[46.188.196.255 198.51.100.10].each do |ip|
      get "/prie", headers: {"CF-Connecting-IP" => ip}
      assert_response :success, "Expected #{ip} not to be blocked"
    end
  end

  test "safelists localhost even when checking subnet blocklist" do
    get "/prie", headers: {"CF-Connecting-IP" => "127.0.0.1"}
    assert_response :success
  end
end
