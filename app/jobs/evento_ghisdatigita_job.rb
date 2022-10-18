# frozen_string_literal: true

class EventoGhisdatigitaJob < ApplicationJob
  queue_as :telegram

  def perform(evento)
    return true if Rails.env.test? || Rails.env.development?

    mesagho = "Evento ĝisdatigita:\n\n"
    mesagho += "<b>#{evento.title}</b>\n\n"
    mesagho += "#{event_url(evento.ligilo)}/kronologio"
    Telegram.send_message(mesagho)
  end
end
