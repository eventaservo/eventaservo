class NovaEventaSciigoJob < ApplicationJob
  queue_as :default

  def perform(evento)
    return true if Rails.env == 'test'

    mesagho = "Nova evento kreita de #{evento.user.name}:\n\n"
    mesagho += "<b>#{evento.title}</b>\n"
    mesagho += "#{ApplicationController.helpers.event_date(evento)}\n"
    mesagho += "#{evento.city} (#{evento.country.code.upcase})\n\n"
    mesagho += "#{evento.description}\n\n"
    mesagho += event_url(evento.code)
    system "telegram-send --config config/es_admin_channel.conf --format html --disable-web-page-preview \"#{mesagho}\""
  end
end
