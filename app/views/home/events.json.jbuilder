# frozen_string_literal: true

json.array!(@events) do |event|
  json.id event.id
  title =
    if event.online?
      "[Enrete] #{event.title}"
    else
      "[#{event.country.code.upcase} - #{event.city}] #{event.title}"
    end
  json.title title
  # json.allDay event.samtaga? ? false : true
  json.allDay event.tuttaga?
  json.description "(#{event.city} - #{event.country.name}) #{event.description}"
  json.start event.komenca_dato

  # FullCalendar montras la malĝustan finan tagon. Pro tio, ES aldonas unu pli tago al la fina dato
  json.end event.multtaga? ? (event.fina_dato + 1.day) : event.fina_dato

  json.url event_url(event.ligilo)
  json.color color_event(event)
end
