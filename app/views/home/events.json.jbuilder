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

  end_date =
    if event.multtaga?
      event.fina_dato + 1.day
    else
      event.fina_dato
    end
  json.end end_date
  json.url event_url(event.code)
  json.color color_event(event)
end
