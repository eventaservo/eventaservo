# frozen_string_literal: true

xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0", "xmlns:atom": "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Eventa Servo - #{params[:continent].capitalize}"
    xml.link events_by_continent_url(continent: params[:continent])
    xml.description "Esperantaj eventoj en #{params[:continent].capitalize}"
    xml.language "eo"
    if @events.any?
      latest = @events.max_by(&:updated_at)
      xml.pubDate latest.updated_at.strftime("%a, %d %b %Y %T %z")
      xml.lastBuildDate latest.updated_at.strftime("%a, %d %b %Y %T %z")
    end
    xml.docs "http://blogs.law.harvard.edu/tech/rss"
    xml.generator "Ruby on Rails"
    xml.managingEditor "kontakto@eventaservo.org (Eventa Servo)"
    xml.webMaster "kontakto@eventaservo.org (Eventa Servo)"
    xml.tag! "atom:link", rel: "self", type: "application/rss+xml", href: events_by_continent_url(continent: params[:continent], format: :xml)

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
