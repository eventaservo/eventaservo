Rails.application.config.after_initialize do
  if Rails.env.in? %w[production staging]
    message = "#{Rails.env.titleize} #{Eventaservo::Application::VERSION} started on #{Socket.gethostname}"
    TelegramSimpleMessenger.send_message(message)
  end
rescue => e
  Sentry.capture_exception(e)
end
