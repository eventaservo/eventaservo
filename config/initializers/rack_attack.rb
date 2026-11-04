# frozen_string_literal: true

class Rack::Attack
  # -------------------------------------------------------------------
  # Extract real visitor IP from Cloudflare header
  # Falls back to req.ip if header not present (e.g., in development)
  #
  # @param req [Rack::Attack::Request] the request object
  # @return [String] the real IP address
  def self.real_ip(req)
    req.env["HTTP_CF_CONNECTING_IP"] || req.ip
  end

  # List of blocked subnets (add problematic subnets here)
  # Example: "47.79.0.0/16" blocks all IPs of 47.79.x.x
  BLOCKED_SUBNETS = [
    # "47.79.0.0/16", # Uncomment to block this range
  ].freeze

  # Legitimate search/AI crawlers. They are never blocked for reading the
  # calendar: blocking them costs SEO and link previews. Their volume is
  # contained by a shared bucket per family instead (see below), so the number
  # of IPs a crawler uses does not matter.
  CRAWLER_FAMILIES = {
    "meta" => /meta-webindexer|meta-externalagent/i,
    "google" => /googlebot/i,
    "bing" => /bingbot/i,
    "apple" => /applebot/i,
    "yandex" => /yandexbot/i
  }.freeze

  # Requests per minute shared by every IP of one crawler family.
  # Calibrated from the NPM logs: production peaks are 41/min (Meta),
  # 43/min (Google), 15/min (Bing) and 10/min (Apple); staging reaches 207/min.
  CRAWLER_LIMIT = 120

  # Scanner thresholds (requests in 10 minutes, per IP). A legitimate crawler
  # gets a much higher allowance, but it is still counted: a spoofed
  # User-Agent must not be able to skip the scanner rule entirely.
  HOME_SCANNER_THRESHOLD = 30
  CRAWLER_HOME_THRESHOLD = 300

  # Returns the crawler family for a User-Agent, or nil for anything else.
  #
  # @param user_agent [String, nil] the request User-Agent
  # @return [String, nil] family key such as "meta" or "google"
  def self.crawler_family(user_agent)
    return nil if user_agent.to_s.empty?

    CRAWLER_FAMILIES.each { |family, pattern| return family if pattern.match?(user_agent) }
    nil
  end

  # Whether the path is the home page, localized or not ("/", "/eo", "/pt_BR").
  #
  # @param path [String] request path
  # @return [Boolean]
  def self.localized_home?(path)
    path.match?(%r{\A/(?:eo|en|pt_BR)?/?\z})
  end

  # Whether the path is an event page, localized or not ("/e/abc", "/en/e/abc").
  #
  # @param path [String] request path
  # @return [Boolean]
  def self.localized_event?(path)
    path.match?(%r{\A/(?:(?:eo|en|pt_BR)/)?e/[^/]+\z})
  end

  # Allow localhost
  safelist("allow-localhost") do |req|
    ip = real_ip(req)
    ip == "127.0.0.1" || ip == "::1"
  end

  # Allow Active Storage proxy requests (lightweight S3 streaming, cached by Cloudflare)
  safelist("allow-active-storage-proxy") do |req|
    req.path.start_with?("/rails/active_storage/representations/proxy/",
      "/rails/active_storage/blobs/proxy/")
  end

  # Block known problematic subnets
  blocklist("block bad subnets") do |req|
    ip = IPAddr.new(real_ip(req))
    BLOCKED_SUBNETS.any? do |subnet|
      IPAddr.new(subnet).include?(ip)
    end
  rescue IPAddr::InvalidAddressError
    false
  end

  # ============================================
  # Behavioral blocking: home-only scanners
  # ============================================
  #
  # Bots systematically scrape the calendar by hitting the home page
  # with varied ?date=&o=&s= parameters but NEVER visit event detail
  # pages (/e/<hash>). Real humans always browse to events after
  # scanning the calendar.
  #
  # This rule detects that pattern:
  # - If an IP makes 30+ home requests in 10 minutes without ever
  #   visiting an /e/ page, it gets blocked for 1 hour.
  # - Visiting any /e/ page clears the suspicion for 1 hour.
  #
  blocklist("block home scanners without event visits") do |req|
    ip = real_ip(req)
    cache = Rack::Attack.cache.store
    # Crawler and human counters are kept apart on purpose: a legitimate
    # crawler must never push a human visitor's counter to the ban threshold,
    # especially behind a shared address (CDN PoP or NAT). The User-Agent can
    # be spoofed, so the crawler bucket still counts and can be banned — it
    # just cannot ban humans sharing the same IP.
    bucket = crawler_family(req.user_agent) ? "c" : "h"
    ban_key = "banned:#{bucket}:#{ip}"
    scan_key = "scan:#{bucket}:#{ip}"
    visit_key = "ev:#{bucket}:#{ip}"

    if localized_home?(req.path) && req.params.key?("date")
      # Check active ban first (persists 1h independently of the 10min counter)
      if cache.read(ban_key)
        Rails.logger.warn "[Rack::Attack] Blocked (already banned) #{ip} - #{req.path}"
        true
      else
        count = cache.increment(scan_key, 1, expires_in: 10.minutes) || 1
        visited_event = cache.read(visit_key)
        threshold = (bucket == "c") ? CRAWLER_HOME_THRESHOLD : HOME_SCANNER_THRESHOLD
        if count >= threshold && !visited_event
          # Persist 1-hour ban so it survives the counter window rolling over
          cache.write(ban_key, true, expires_in: 1.hour)
          Rails.logger.warn "[Rack::Attack] Blocked (scanner threshold) #{ip} bucket=#{bucket} - #{count} home requests, no event visit - banned for 1h"
          true
        end
      end
    elsif localized_event?(req.path)
      # If this bucket was banned, visiting an event page clears the ban
      cache.delete(ban_key)
      cache.write(visit_key, true, expires_in: 1.hour)
      false
    end
  end

  # ============================================
  # Crawler volume (legitimate crawlers)
  # ============================================
  #
  # One bucket per family, shared by every IP the crawler uses. This keeps the
  # calendar readable for search engines while stopping a single crawler from
  # consuming the origin. Limit calibrated from the NPM access logs.
  throttle("crawler volume", limit: CRAWLER_LIMIT, period: 60) do |req|
    crawler_family(req.user_agent)
  end

  # ============================================
  # Throttle by individual IP
  # ============================================
  #
  # NOTE: All IP-based throttles are DISABLED because the site is served
  # behind a CDN (G-Core). The CDN edge PoPs terminate client connections,
  # so `real_ip` (and even `req.ip`) resolves to the PoP IP address, not the
  # visitor's. Thousands of real visitors share a single PoP IP, so any
  # per-IP throttle causes mass 429 responses (observed: ~400 throttles in
  # 2h, all from PoP 93.123.17.151). Rate limiting is now handled at the
  # WAF layer (BunkerWeb), which sits in front of the origin.
  #
  # Re-enable only if the app moves to a setup where the visitor IP is
  # available (direct origin access or CDN real-IP header support).

  # General limit: 5 requests per second per IP
  # throttle("requests by IP", limit: 5, period: 1) do |req|
  #   real_ip(req)
  # end

  # Longer limit: 120 requests per minute per IP
  # Allows real users to navigate the calendar (up to ~35 week clicks + overhead)
  # throttle("requests by IP per minute", limit: 120, period: 60) do |req|
  #   real_ip(req)
  # end

  # ============================================
  # API throttling
  # ============================================

  # throttle("limit API requests per IP", limit: 2, period: 10) do |req|
  #   real_ip(req) if req.path == "/api/v2/organizations"
  # end

  # ============================================
  # Login throttling
  # ============================================
  #
  # The email-based throttle is KEPT: the discriminator is the account
  # email, not the IP, so it is not affected by the CDN PoP IP collision.
  # It protects against brute-force password guessing per account.
  #
  # NOTE: the Devise sign-in form posts `user[email]` (nested params), so
  # `req.params["email"]` is always nil. The nested lookup must come first.

  throttle("limit logins per email", limit: 3, period: 60) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params.dig("user", "email") || req.params["email"]
    end
  end

  # Disabled: IP-based, suffers from the CDN PoP IP collision.
  # throttle("limit logins per IP", limit: 5, period: 60) do |req|
  #   real_ip(req) if req.path == "/users/sign_in" && req.post?
  # end
end

# ============================================
# Logging and notifications
# ============================================

ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |name, start, finish, request_id, payload|
  req = payload[:request]
  visitor_ip = req.env["HTTP_CF_CONNECTING_IP"] || req.ip
  discriminator = payload.dig(:match_data, :discriminator)
  Rails.logger.warn "[Rack::Attack] Throttled #{visitor_ip} - #{req.path} - #{payload[:match_type]}: #{discriminator}"
end

ActiveSupport::Notifications.subscribe("blocklist.rack_attack") do |name, start, finish, request_id, payload|
  req = payload[:request]
  visitor_ip = req.env["HTTP_CF_CONNECTING_IP"] || req.ip
  Rails.logger.warn "[Rack::Attack] Blocked #{visitor_ip} - #{req.path}"
end

# Custom response for blocked/throttled requests
Rack::Attack.blocklisted_responder = lambda do |request|
  [403, {"Content-Type" => "text/plain"}, ["Forbidden\n"]]
end

Rack::Attack.throttled_responder = lambda do |request|
  match_data = request.env["rack.attack.match_data"]
  now = match_data[:epoch_time]
  retry_after = match_data[:period] - (now % match_data[:period])

  [
    429,
    {
      "Content-Type" => "text/plain",
      "Retry-After" => retry_after.to_s
    },
    ["Too Many Requests. Retry later.\n"]
  ]
end
