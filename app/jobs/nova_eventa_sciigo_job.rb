# frozen_string_literal: true

class NovaEventaSciigoJob < ApplicationJob
  queue_as :low

  def perform(evento)
    return true if Rails.env.test? || Rails.env.development?

    mesagho = "Nova evento kreita de #{evento.user.name}:\n\n"
    mesagho += "<b>#{evento.title}</b>\n"
    mesagho += "#{ApplicationController.helpers.event_date(evento)}\n"
    mesagho += "#{evento.city} (#{evento.country.code.upcase})\n\n"
    mesagho += "#{evento.description}\n\n"
    mesagho += event_url(code: evento.ligilo)
    Telegram.send_message(mesagho)
  end
end
