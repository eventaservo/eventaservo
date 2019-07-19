# frozen_string_literal: true

module EventImporter
  require 'httparty'
  require 'nokogiri'

  def importas_eksteran_eventon(url)
    evento = {}
    eraro = ""
    if url == ""
      return evento, "importa URL estas bezonata por importi eventojn."
    end

    l = url.scan(URI.regexp)[0]

    if l[3] == "www.meetup.com"
      evento, eraro = importas_el_meetup(url)
    elsif l[3] == "events.duolingo.com"
      evento, eraro = importas_el_duolingo(url)
    else
      return evento, "importado ne subtenata por #{l[3]}"
    end

    return evento, eraro
  end

  def importas_el_meetup(url)
    evento = {}
    l = url.scan(URI.regexp)[0]
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

  def importas_el_duolingo(url)
    evento = {}
    l = url.scan(URI.regexp)[0]
    idx = l[6].split("/").index("events")
    if idx == nil
      return evento, "importa URL. Bezonata formato estas 'https://events.duolingo.com/events/details/:id/'"
    end

    # Prenu adreson de la evento por serĉi koordinatojn
    res = HTTParty.get(url)
    if res.code != 200
      code = res["errors"][0]["code"]
      message = res["errors"][0]["message"]
      retrokuplo = "[#{code}] #{message}"

      return evento, "importado ne sukcesis: #{retrokuplo}"
    end

    pagxo = Nokogiri::HTML(res)
    adreso = pagxo.css(".address-info")[1]\
              .content.split("\n")\
              .map{|a| a.strip}\
              .filter{|a| a if a != "" && a.downcase() != "where"}\
              .join(", ")


    geo_sercxo = Geocoder.search(adreso).first 
    lando = geo_sercxo.country == "Unuiĝinta Reĝlando" ? "Britio" : geo_sercxo.country
    koordinatoj = geo_sercxo.coordinates

    # Uzu kordinatoj por serĉi la eventon en la listo de eventoj
    proksimeco = 100
    sercxurl = "https://events.duolingo.com/api/search/?result_types=upcoming_event&latitude=#{koordinatoj[0]}&longitude=#{koordinatoj[1]}&proximity=#{proksimeco}&event_type_slug=fireside-chat&event_type_slug=testing-recurring&event_type_slug=paid-event"
    res = HTTParty.get(sercxurl)
    if res.code != 200
      code = res["errors"][0]["code"]
      message = res["errors"][0]["message"]
      retrokuplo = "[#{code}] #{message}"

      return evento, "importado ne sukcesis: #{retrokuplo}"
    end

    eventa_listo = res["results"].filter{|e| e if e["url"] == url}
    if eventa_listo.length() == 0 
      return evento, "importado ne sukcesis: evento ne trovita"
    end
    
    # Uzu la eventoan id-n kun la eventa API
    eventa_api_url = "https://events.duolingo.com/api/event/#{eventa_listo[0]["id"].to_s}"
    res = HTTParty.get(eventa_api_url)
    if res.code != 200
      code = res["errors"][0]["code"]
      message = res["errors"][0]["message"]
      retrokuplo = "[#{code}] #{message}"

      return evento, "importado ne sukcesis: #{retrokuplo}"
    end

    evento["title"] = res["chapter"]["title"] + res["title"]
    evento["city"] = res["venue_city"]
    evento["site"] = res["url"]
    evento["country_id"] = Country.by_name(lando).id
    evento["latitude"] = koordinatoj[0]
    evento["longitude"] = koordinatoj[1]
    evento["address"] = adreso
    evento["time_zone"] = Timezone.lookup(evento["latitude"], evento["longitude"]).name
    evento["date_start"] = Time.parse(res["start_date_naive"]).utc
    evento["date_end"] = Time.parse(res["end_date_naive"]).utc
    evento["content"] = res["description"]
    evento["description"] = res["description_short"]
    evento["site"] = res["url"]

    return evento, ""
  end

end
