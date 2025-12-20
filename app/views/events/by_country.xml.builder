# frozen_string_literal: true

xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0", "xmlns:atom": "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Eventa Servo - #{@country.name}"
    xml.link events_by_country_url(continent: @country.continent.normalized, country_name: @country.name.normalized)
    xml.description "Esperantaj eventoj en #{@country.name}"
    xml.language "eo"
    if @events.any?
      xml.pubDate @events.order(updated_at: :desc).first.updated_at.strftime("%a, %d %b %Y %T %z")
      xml.lastBuildDate @events.order(updated_at: :desc).first.updated_at.strftime("%a, %d %b %Y %T %z")
    end
    xml.docs "http://blogs.law.harvard.edu/tech/rss"
    xml.generator "Ruby on Rails"
    xml.managingEditor "kontakto@eventaservo.org (Eventa Servo)"
    xml.webMaster "kontakto@eventaservo.org (Eventa Servo)"
    xml.tag! "atom:link", rel: "self", type: "application/rss+xml", href: events_by_country_url(continent: @country.continent.normalized, country_name: @country.name.normalized, format: :xml)

    @events.each do |event|
      xml.item do
        xml.title event.title
        xml.link event_url(code: event.code)
        xml.description event_full_description(event)
        rss_enclosure(xml, event)
        xml.pubDate event.updated_at.strftime("%a, %d %b %Y %T %z")
        xml.guid event_url(code: event.code), isPermaLink: true
      end
    end
  end
end
