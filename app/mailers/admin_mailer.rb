# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def informas(teksto)
    mail(to: Constants::ADMIN_EMAILS, subject: '[ES programistoj] Informo', body: teksto)
  end
end
