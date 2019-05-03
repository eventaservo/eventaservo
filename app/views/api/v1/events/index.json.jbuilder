# frozen_string_literal: true

json.array!(@events) do |event|
  json.uuid event.uuid
  json.kodo event.code
  json.titolo event.title
  json.priskribo event.description
  json.enhavo event.content
  json.komenca_dato event.date_start.strftime('%Y-%m-%d')
  json.fina_dato event.date_end.strftime('%Y-%m-%d')
  json.retpaĝo event.site.presence
  json.retpoŝtadreso event.email.presence
  json.organizoj event.organizations.pluck(:name) if event.organizations.any?

  if event.online
    json.reta true
    json.loko nil
  else
    json.reta false
    json.loko do |loko|
      loko.adreso event.address.presence
      loko.urbo event.city
      loko.lando event.country.name
      loko.landokodo event.country.code
      loko.kontinento event.country.continent
      loko.latitudo event.latitude
      loko.longitudo event.longitude
    end
  end
  json.administranto event.user.name
end
