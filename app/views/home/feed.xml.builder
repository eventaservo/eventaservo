xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title 'Eventa Servo'
    xml.description 'Venontaj eventoj'
    xml.link root_url
    xml.language 'eo'
    xml.managingEditor 'kontakto@eventaservo.org'
    xml.webMaster 'kontakto@eventaservo.org'
    xml.pubDate @events.order(updated_at: :desc).last.updated_at.strftime('%a, %d %b %Y %T %z')
    xml.lastBuildDate @events.order(updated_at: :desc).last.updated_at.strftime('%a, %d %b %Y %T %z')

    @events.includes(:user).each do |event|
      xml.item do
        xml.title event.title
        xml.description event_full_description(event)
        xml.author event.user.name
        xml.pubDate event.updated_at.strftime('%a, %d %b %Y %T %z')
        xml.guid event_url(event.code), isPermaLink: true

      end
    end
  end
end