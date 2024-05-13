# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def notify(subject:, body:)
    mail(to: Constants::ADMIN_EMAILS, subject:, body:)
  end

  # Notifies the DevOps team that the application has started
  def startup_notifier
    to = "fernando@eventaservo.org"
    date = Time.zone.now.strftime("%d/%m/%Y %H:%M")
    host = Socket.gethostname
    subject = "[EventaServo] #{Rails.env.titleize} #{Eventaservo::Application::VERSION} started"
    body = "#{host} | #{date}"

    mail(to:, subject:, body:)
  end
end
