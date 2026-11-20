# frozen_string_literal: true

json.uuid event.uuid
json.code event.code
json.short_url event.short_url.presence
json.title event.title
json.description event.description
json.content event.enhavo.to_s.presence || event.content.presence
json.date_start event.date_start.in_time_zone(event.time_zone).iso8601
json.date_end event.date_end.in_time_zone(event.time_zone).iso8601
json.time_zone event.time_zone
json.site event.site.presence
json.email event.email.presence
json.international_calendar event.international_calendar
json.format event.format || Api::V2::Events::AttributeResolver.compute_format(event)
json.online event.online
json.cancelled event.cancelled
json.cancel_reason event.cancel_reason.presence

if event.universala?
  json.location nil
else
  json.location do
    json.address event.address.presence
    json.city event.city
    json.country event.country&.name
    json.country_code event.country&.code
    json.continent event.country&.continent
    json.latitude event.latitude
    json.longitude event.longitude
  end
end

json.organizations event.organizations do |org|
  json.short_name org.short_name
  json.name org.name
end

json.tags event.tags.select { |tag| Api::V2::Events::AttributeResolver::ALLOWED_TAG_GROUPS.include?(tag.group_name) }.map(&:name)
json.organizer event.user.name
json.url event_url(code: event.ligilo)
json.created_at event.created_at.utc.iso8601
json.updated_at event.updated_at.utc.iso8601
