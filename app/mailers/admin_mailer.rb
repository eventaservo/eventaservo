# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def notify(subject:, body:)
    mail(to: Constants::ADMIN_EMAILS, subject:, body:)
  end

  # Notifies the DevOps team that the application has started
  def startup_notifier
    host = Socket.gethostname
    return if host == "buildkitsandbox" # Skips GitHub Actions builds

    to = "fernando@eventaservo.org"
    date = Time.zone.now.strftime("%d/%m/%Y %H:%M")
    subject = "[EventaServo] #{Rails.env.titleize} #{Eventaservo::Application::VERSION} started"
    body = "#{host} | #{date}"

    mail(to:, subject:, body:)
  end
end
