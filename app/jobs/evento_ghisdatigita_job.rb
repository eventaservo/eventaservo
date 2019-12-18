class EventoGhisdatigitaJob < ApplicationJob
  queue_as :default

  def perform(evento)
    return true if Rails.env == 'test'

    mesagho = "Evento ĝisdatigita:\n\n"
    mesagho += "<b>#{evento.title}</b>\n\n"
    mesagho += event_url(evento.ligilo) + '/kronologio'
    system "telegram-send --config config/es_admin_channel.conf --format html --disable-web-page-preview \"#{mesagho}\""
  end
end
