# frozen_string_literal: true

require "test_helper"

# Guards the home page cache for the ad selection.
class HomeController::IndexCacheTest < ActionDispatch::IntegrationTest
  KALENDARO = {"Cookie" => "vidmaniero=kalendaro"}

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
