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
  json.allDay event.samtaga? ? false : true
  json.description "(#{event.city} - #{event.country.name}) #{event.description}"
  json.start event.komenca_dato
  json.end event.fina_dato
  json.url event_url(event.code)
  json.color color_event(event)
end
