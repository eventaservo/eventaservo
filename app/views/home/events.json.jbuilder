json.array!(@events) do |event|
  json.extract! event, :id, :title
  json.description "(#{event.city} - #{event.country.name}) #{event.description}"
  json.start event.date_start.beginning_of_day
  json.end event.date_end.end_of_day
  json.url event_url(event.code)
  json.color color_event(event)
end
