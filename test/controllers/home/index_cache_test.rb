# frozen_string_literal: true

require "test_helper"

# Guards the home page caches for event counts and ad selection.
class HomeController::IndexCacheTest < ActionDispatch::IntegrationTest
  KALENDARO = {"Cookie" => "vidmaniero=kalendaro"}

  test "reuses cached event counts on the next request" do
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    get "/eo", headers: KALENDARO
    assert_response :success

    count_queries = []
    callback = lambda do |*, payload|
      next if payload[:name] == "SCHEMA" || payload[:cached]
      count_queries << payload[:sql] if payload[:sql].match?(/SELECT COUNT/i)
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      get "/eo", headers: KALENDARO
    end

    assert_response :success
    assert_empty count_queries, "expected counts from cache, got: #{count_queries.first(3).inspect}"
  ensure
    Rails.cache = original_cache
  end

  test "populates the ad selection cache" do
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    get "/eo", headers: KALENDARO
    assert_response :success

    ad_ids = Rails.cache.read("home_ad_ids_v1")
    assert_not_nil ad_ids
    assert_operator ad_ids.size, :<=, 4
  ensure
    Rails.cache = original_cache
  end
end
