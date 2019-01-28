xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0', 'xmlns:atom':  "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title 'Eventa Servo'
    xml.description 'Venontaj eventoj'
    xml.link root_url
    xml.language 'eo'
    xml.webMaster 'kontakto@eventaservo.org (Eventa Servo)'
    xml.pubDate @events.order(updated_at: :desc).last.updated_at.strftime('%a, %d %b %Y %T %z')
    xml.lastBuildDate @events.order(updated_at: :desc).last.updated_at.strftime('%a, %d %b %Y %T %z')
    xml.tag! 'atom:link', rel: 'self', type: 'application/rss+xml', href: events_rss_url

    @events.includes(:user).each do |event|
      xml.item do
        xml.title event.title
        xml.description event_full_description(event)
        xml.pubDate event.updated_at.strftime('%a, %d %b %Y %T %z')
        xml.guid event_url(event.code), isPermaLink: true
      end
    end
  end
end