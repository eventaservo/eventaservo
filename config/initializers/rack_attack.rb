class Rack::Attack
  safelist("allow-localhost") do |req|
    req.ip == "127.0.0.1" || req.ip == "::1"
  end

  throttle("limit API requests per IP", limit: 2, period: 10) do |req|
    if req.path == "/api/v2/organizations"
      req.ip
    end
  end

  throttle("requets by IP", limit: 30, period: 1) do |req|
    req.ip
  end

  throttle("limit logins per email", limit: 3, period: 60) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params["email"]
    end
  end
end

ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |name, start, finish, request_id, payload|
  Rails.logger.info "RACK_ATTACK: #{payload}"
  # AdminMailer.rack_attack_payload(payload).deliver
end
