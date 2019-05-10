class Rack::Attack
  safelist('allow-localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  throttle('requets by IP', limit: 25, period: 5) do |req|
    req.ip
  end

  throttle('limit logins per email', limit: 3, period: 60) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.params['email']
    end
  end
end

class NotificationsMailer < ApplicationMailer
  def rack_mailer(payload)
    mail(to: 'kontakto@eventaservo.org', subject: 'Rack attack log info') do
      render plain: payload
    end
  end
end

ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, start, finish, request_id, payload|
  Rails.logger.debug "RACK_ATTACK: #{payload}"
  NotificationMailer.rack_mailer(payload).deliver_later
end
