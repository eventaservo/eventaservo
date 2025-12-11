# frozen_string_literal: true

class Rack::Attack
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
  # Throttle by individual IP
  # ============================================

  # General limit: 5 requests per second per IP
  throttle("requests by IP", limit: 5, period: 1) do |req|
    real_ip(req)
  end

  # Longer limit: 60 requests per minute per IP
  throttle("requests by IP per minute", limit: 60, period: 60) do |req|
    real_ip(req)
  end

  # ============================================
  # Throttle by Subnet (/24 - e.g.: 47.79.215.x)
  # This limits when multiple IPs from the same range attack
  # ============================================

  # Extract /24 subnet from IP (e.g.: 47.79.215.131 -> 47.79.215)
  throttle("requests by subnet /24", limit: 30, period: 10) do |req|
    ip = real_ip(req)
    ip.to_s.split(".")[0, 3].join(".") if ip.present?
  end

  # Broader /16 subnet (e.g.: 47.79.x.x -> 47.79)
  # For distributed attacks within the same larger block
  throttle("requests by subnet /16", limit: 100, period: 60) do |req|
    ip = real_ip(req)
    ip.to_s.split(".")[0, 2].join(".") if ip.present?
  end

  # ============================================
  # Throttle for heavy routes
  # ============================================

  # Homepage - very heavy (20 queries according to logs)
  throttle("homepage requests by IP", limit: 3, period: 10) do |req|
    real_ip(req) if req.path == "/" && req.get?
  end

  # Continent pages (also heavy)
  CONTINENT_PATHS = %w[/europo /ameriko /azio /afriko /oceanio /reta].freeze
  throttle("continent pages by IP", limit: 3, period: 10) do |req|
    real_ip(req) if req.get? && CONTINENT_PATHS.include?(req.path)
  end

  # Throttle by subnet for heavy routes
  throttle("heavy pages by subnet /24", limit: 10, period: 30) do |req|
    if req.get? && (req.path == "/" || CONTINENT_PATHS.include?(req.path))
      real_ip(req).to_s.split(".")[0, 3].join(".")
    end
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
