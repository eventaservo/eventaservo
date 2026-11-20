# frozen_string_literal: true

json.events do
  json.array!(@events) do |event|
    json.partial! "api/v2/managed_events/event", event:
  end
end

json.meta do
  json.page @pagy.page
  json.per_page @pagy.limit
  json.total_count @pagy.count
  json.total_pages @pagy.pages
end
