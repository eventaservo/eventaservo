# frozen_string_literal: true

class Rack::Attack
  # Ensure a proper cache store for counters.
  # Rails.cache defaults to :memory_store in production,
  # but Rack::Attack needs its own store for atomic counters.
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
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
  # Example: "47.79.0.0/16" blocks all IPs 47.79.x.x
  BLOCKED_SUBNETS = [
    # "47.79.0.0/16", # Uncomment to block this range
  ].freeze

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

    if req.path == "/" && req.params.key?("date")
      # Check active ban first (persists 1h independently of the 10min counter)
      if Rack::Attack.cache.read("banned:#{ip}")
        Rails.logger.warn "[Rack::Attack] Blocked (already banned) #{ip} - #{req.path}"
        true
      else
        count = Rack::Attack.cache.count("scan:#{ip}", 10.minutes).to_i
        visited_event = Rack::Attack.cache.read("ev:#{ip}")
        if count >= 30 && !visited_event
          # Persist 1-hour ban so it survives the counter window rolling over
          Rack::Attack.cache.write("banned:#{ip}", true, expires_in: 1.hour)
          Rails.logger.warn "[Rack::Attack] Blocked (scanner threshold) #{ip} - #{count} home requests, no event visit - banned for 1h"
          true
        end
      end
    elsif req.path.match?(/\A\/e\/[^\/]+\z/)
      # Grant exemption for any valid event path: /e/<code> where code is
      # a short hash (e.g. /e/2053c2) or a named slug (e.g. /e/nome-do-evento).
      # Resources :events, path: "e", param: "code" in config/routes/events.rb
      # If the IP was banned, visiting an event page clears the ban
      Rack::Attack.cache.delete("banned:#{ip}")
      Rack::Attack.cache.write("ev:#{ip}", true, expires_in: 1.hour)
      false
    end
  end

  # ============================================
  # Throttle by individual IP
  # ============================================

  # General limit: 5 requests per second per IP
  throttle("requests by IP", limit: 5, period: 1) do |req|
    real_ip(req)
  end

  # Longer limit: 120 requests per minute per IP
  # Allows real users to navigate the calendar (up to ~35 week clicks + overhead)
  throttle("requests by IP per minute", limit: 120, period: 60) do |req|
    real_ip(req)
  end

  # ============================================
  # API throttling
  # ============================================

  throttle("limit API requests per IP", limit: 2, period: 10) do |req|
    real_ip(req) if req.path == "/api/v2/organizations"
  end

  # ============================================
  # Login throttling
  # ============================================

  throttle("limit logins per email", limit: 3, period: 60) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params["email"]
    end
  end

  throttle("limit logins per IP", limit: 5, period: 60) do |req|
    real_ip(req) if req.path == "/users/sign_in" && req.post?
  end
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
