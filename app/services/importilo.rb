# frozen_string_literal: true

class Importilo
  require 'httparty'
  require 'nokogiri'

  def initialize(url)
    @url = url
  end

  def retejo
    case URI(@url).host
    when 'www.meetup.com'
      'Meetup'
    when 'events.duolingo.com'
      'Duolingo'
    else
      false
    end
  end

  def datumoj
    return nil unless url_estas_valida

    return importas_el_meetup if retejo == 'Meetup'
    return importas_el_duolingo if retejo == 'Duolingo'
  end

  private

    def url_estas_valida
      case retejo
      when 'Meetup', 'Duolingo'
        # Bezonata formato por Meetup estas 'https://www.meetup.com/:grupo/events/:id/'"
        # Bezonata formato por Duolingo estas 'https://events.duolingo.com/events/details/:id/
        URI(@url).path.split('/').index('events') != nil
      else
        false
      end
    end

    def importas_el_meetup
      evento = {}
      path   = URI(@url).path

      idx = path.split('/').index('events')

      grupo = path.split('/')[idx - 1]
      id    = path.split('/')[idx + 1]

      res = HTTParty.get("https://api.meetup.com/#{grupo}/events/#{id}")

      if res.code != 200
        code       = res['errors'][0]['code']
        message    = res['errors'][0]['message']
        retrokuplo = "[#{code}] #{message}"

        if res.code == 404
          if code == 'event_error' && message == 'invalid event'
            retrokuplo = "evento '#{id}' ne ekzistas"
          elsif code == 'group_error' && message.start_with?('Invalid group urlname')
            retrokuplo = "grupo '#{grupo}' ne ekzistas"
          end
        end

        Rails.logger.error "Meetup importado ne sukcesis: #{retrokuplo}"
        return nil
      end

      evento['title']       = res['group']['name'] + ': ' + res['name']
      evento['city']        = res['venue']['city'] ? res['venue']['city'] : 'Nekonata'
      evento['site']        = res['link']
      evento['country_id']  = Country.by_code(res['venue']['country']).id
      evento['latitude']    = res['venue']['lat']
      evento['longitude']   = res['venue']['lon']
      evento['address']     = "#{res['venue']['name']}, #{res['venue']['address_1']}"
      evento['time_zone']   = Timezone.lookup(evento['latitude'], evento['longitude']).name
      evento['date_start']  = Time.at(res['time'].to_i / 1000).in_time_zone(evento['time_zone']).strftime("%Y-%m-%d %H:%M:%S")
      evento['date_end']    = Time.at((res['time'].to_i + res['duration'].to_i) / 1000).in_time_zone(evento['time_zone']).strftime("%Y-%m-%d %H:%M:%S")
      evento['content']     = res['description'] + res.fetch('how_to_find_us', '')
      evento['description'] = res['name']
      evento['site']        = res['link']

      evento
    end

    def importas_el_duolingo
      evento = {}

      # Prenu adreson de la evento por serĉi koordinatojn
      pagxo  = Nokogiri::HTML(HTTParty.get(@url))

      # Teksto kiam devus respondi kun 404
      if pagxo.text == "Events - Duolingo"
        Rails.logger.error "Duolingo importado ne sukcesis: malbona URL"
        return nil
      end

      eventa_id = pagxo.css('form')[0]["eventid"]

      # Uzu la eventoan id-n kun la eventa API
      eventa_api_url = "https://events.duolingo.com/api/event/#{eventa_id}"
      res            = HTTParty.get(eventa_api_url)
      if res.code != 200
        code       = res["errors"][0]["code"]
        message    = res["errors"][0]["message"]
        retrokuplo = "[#{code}] #{message}"

        Rails.logger.error "Duolingo importado ne sukcesis: #{retrokuplo}"
        return nil
      end

      adreso = "#{res['venue_name']}, #{res['venue_address']}, #{res["venue_city"]}, #{res["venue_zip_code"]}"
      geo_sercxo  = Geocoder.search(adreso).first
      koordinatoj = geo_sercxo.coordinates

      evento["title"]       = res["chapter"]["title"] + res["title"]
      evento["city"]        = res["venue_city"]
      evento["site"]        = res["url"]
      evento["country_id"]  = res["chapter"]["country"]
      evento["latitude"]    = koordinatoj[0]
      evento["longitude"]   = koordinatoj[1]
      evento["address"]     = adreso
      evento["time_zone"]   = Timezone.lookup(evento["latitude"], evento["longitude"]).name
      evento["date_start"]  = Time.find_zone(evento["time_zone"]).parse(res["start_date_naive"]).in_time_zone(evento['time_zone']).strftime("%Y-%m-%d %H:%M:%S")
      evento["date_end"]    = Time.find_zone(evento["time_zone"]).parse(res["end_date_naive"]).in_time_zone(evento['time_zone']).strftime("%Y-%m-%d %H:%M:%S")
      evento["content"]     = res["description"]
      evento["description"] = res["description_short"]
      evento["site"]        = res["url"]

      return evento
    end
end
