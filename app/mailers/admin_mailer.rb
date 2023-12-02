# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def notify(subject:, body:)
    mail(to: Constants::ADMIN_EMAILS, subject:, body:)
  end
end
