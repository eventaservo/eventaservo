# frozen_string_literal: true

module Meetup
  require 'httparty'

  def sercxas_evento(url)
    evento = {}
    if url == ""
      return evento, "importa URL estas bezonata por importi eventojn."
    end

    l = url.scan(URI.regexp)[0]

    if l[3] != "www.meetup.com"
      return evento, "importado ne subtenata por #{l[3]}"
    end

    idx = l[6].split("/").index("events")
    if idx == nil
      return evento, "importa URL. Bezonata formato estas 'https://www.meetup.com/:grupo/events/:id/'"
    end

    grupo = l[6].split("/")[idx-1]
    id = l[6].split("/")[idx+1]

    res = HTTParty.get("https://api.meetup.com/#{grupo}/events/#{id}")

    if res.code != 200
      code = res["errors"][0]["code"]
      message = res["errors"][0]["message"]
      retrokuplo = "[#{code}] #{message}"

      if res.code == 404
        if code == "event_error" && message == "invalid event"
          retrokuplo = "evento '#{id}' ne ekzistas"
        elsif code == "group_error" && message.start_with?("Invalid group urlname")
          retrokuplo = "grupo '#{grupo}' ne ekzistas"
        end
      end

      return evento, "importado ne sukcesis: #{retrokuplo}"
    end

    evento["title"] = res["group"]["name"] + ": " + res["name"]
    evento["city"] = res["venue"]["city"]
    evento["site"] = res["link"]
    evento["country_id"] = Country.by_code(res["venue"]["country"]).id
    evento["latitude"] = res["venue"]["lat"]
    evento["longitude"] = res["venue"]["lon"]
    evento["address"] = "#{res['venue']['name']}, #{res['venue']['address_1']}"
    evento["time_zone"] = Timezone.lookup(evento["latitude"], evento["longitude"]).name
    evento["date_start"] = Time.at(res["time"].to_i / 1000).utc
    evento["date_end"] = Time.at((res["time"].to_i + res["duration"].to_i) / 1000).utc
    evento["content"] = res["description"] + res.fetch("how_to_find_us", "")
    evento["description"] = res["name"]
    evento["site"] = res["link"]

    return evento, ""
  end

end
