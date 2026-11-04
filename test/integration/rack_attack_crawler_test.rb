# frozen_string_literal: true

require "test_helper"

# Covers the crawler rules in config/initializers/rack_attack.rb: legitimate
# search/AI crawlers are throttled by family instead of being blocked, and the
# home-scanner blocklist now recognizes localized home paths.
class RackAttackCrawlerTest < ActionDispatch::IntegrationTest
  META_UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) " \
    "Chrome/145.0.0.0 Safari/537.36 (compatible; meta-webindexer/1.1; " \
    "+https://developers.facebook.com/docs/sharing/webmasters/crawler)"
  GOOGLE_UA = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
  HUMAN_UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) " \
    "Chrome/131.0.0.0 Safari/537.36"

  setup do
    # The test environment uses :null_store, which would make Rack::Attack
    # counters invisible. Give it a real in-memory store per test.
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  test "detects the crawler family from the user agent" do
    assert_equal "meta", Rack::Attack.crawler_family(META_UA)
    assert_equal "google", Rack::Attack.crawler_family(GOOGLE_UA)
    assert_nil Rack::Attack.crawler_family(HUMAN_UA)
    assert_nil Rack::Attack.crawler_family(nil)
  end

  test "recognizes the home page with and without locale" do
    assert Rack::Attack.localized_home?("/")
    assert Rack::Attack.localized_home?("/eo")
    assert Rack::Attack.localized_home?("/en/")
    assert Rack::Attack.localized_home?("/pt_BR")
    refute Rack::Attack.localized_home?("/e/0c9e59")
    refute Rack::Attack.localized_home?("/eo/europo")
  end

  test "throttles a crawler family after the limit and sends Retry-After" do
    travel_to Time.zone.parse("2026-11-04 12:00:00") do
      Rack::Attack::CRAWLER_LIMIT.times do
        get "/nao-existe", headers: {"User-Agent" => META_UA, "CF-Connecting-IP" => "203.0.113.7"}
      end
      assert_response :redirect

      get "/nao-existe", headers: {"User-Agent" => META_UA, "CF-Connecting-IP" => "203.0.113.7"}

      assert_response :too_many_requests
      assert_predicate response.headers["Retry-After"], :present?
    end
  end

  test "throttles each crawler family in its own bucket" do
    travel_to Time.zone.parse("2026-11-04 12:00:00") do
      Rack::Attack::CRAWLER_LIMIT.times do
        get "/nao-existe", headers: {"User-Agent" => META_UA, "CF-Connecting-IP" => "203.0.113.7"}
      end
      get "/nao-existe", headers: {"User-Agent" => META_UA, "CF-Connecting-IP" => "203.0.113.7"}
      assert_response :too_many_requests

      get "/nao-existe", headers: {"User-Agent" => GOOGLE_UA, "CF-Connecting-IP" => "203.0.113.8"}
      assert_response :redirect
    end
  end

  test "blocks a localized home scanner that never visits an event" do
    Rack::Attack.cache.store.write("scan:203.0.113.5", 29, expires_in: 10.minutes)

    get "/eo?date=2026-01-01", headers: {"User-Agent" => HUMAN_UA, "CF-Connecting-IP" => "203.0.113.5"}

    assert_response :forbidden
  end

  test "does not block a legitimate crawler with the home scanner rule" do
    Rack::Attack.cache.store.write("scan:203.0.113.6", 29, expires_in: 10.minutes)

    get "/eo?date=2026-01-01", headers: {"User-Agent" => META_UA, "CF-Connecting-IP" => "203.0.113.6"}

    refute_equal 403, response.status
  end
end
