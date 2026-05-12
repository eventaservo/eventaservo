json.eventKvanto @events.size
json.organizKvanto @organizations.size
json.eventoj do
  json.array! @events do |evento|
    json.id evento.id

    fajro = "🔥 " if evento.participants.size > Constants::FAJRA_EVENTO_PARTOPRENONTOJ
    json.titolo "#{fajro} #{event_flag(evento)} #{evento.title}"

    json.city evento.city
    json.klass event_color_class(evento)
    json.ligilo evento.ligilo
    json.priskribo evento.description
    json.dato event_date(evento)
    json.nuligita evento.cancelled
  end
end

json.organizoj do
  json.array! @organizations do |organizo|
    json.id organizo.id

    flago = montras_flagon(organizo.country) unless organizo.country.nil?
    json.nomo "#{flago} #{organizo.name}"

    json.mallongilo organizo.short_name
  end
end

json.uzantoj do
  json.array! @users do |uzanto|
    json.nomo uzanto.name
    json.uzantnomo uzanto.username
    json.lando uzanto.country.name
  end
end

json.videoj do
  json.array! @videos do |video|
    json.id video.id
    json.titolo video.title
    json.priskribo video.description
    json.evento video.evento.title
    json.dato format_date(video.evento.komenca_dato, style: :month_year).downcase
    json.url video.url
  end
end
