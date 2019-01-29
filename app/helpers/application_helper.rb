# frozen_string_literal: true

module ApplicationHelper
  def page_title(title, subtext = nil)
    content_tag(:h2, raw("#{title} <small>#{subtext}</small>"), class: 'text-center')
  end

  def flash_class(level)
    case level
    when :notice then
      'alert alert-primary alert-dismissible'
    when :success then
      'alert alert-success alert-dismissible'
    when :error then
      'alert alert-danger alert-dismissible'
    when :alert then
      'alert alert-warning alert-dismissible'
    else
      'alert alert-info alert-dismissible'
    end
  end

  def error_handling(record)
    return unless record.errors.any?

    return_html = "<div class='error-handling'>"
    return_html += '<h4>Erros foram encontrados neste formulário</h4>'
    return_html += '<ul>'

    record.errors.full_messages.each do |msg|
      return_html += "<li>#{msg}</li>"
    end

    return_html += '</ul></div>'

    raw return_html
  end

  # Stiloj:
  #   default   = 1-a de Januaru de 2019
  #   :short    = 01/Jan/19
  def format_date(date, style: nil)
    case style
    when :short then l(date, format: '%e/%b/%y').strip
    else l(date, format: "%A, %e %B %Y").strip
    end
  end

  # Simpligas la eventajn datojn
  def event_date(event)
    ds = event.date_start
    de = event.date_end
    return format_date(ds) if ds == de # Samtaga

    if de.year == ds.year # Samjara
      if de.month == ds.month # Sammonata
        "#{ds.day} - #{de.day} #{l(de, format: '%B %Y')}"
      else # malsammonata
        "#{l(ds, format: '%e %B')} - #{l(de, format: '%e %B %Y')}"
      end
    else # malsamjara
      "#{l(ds, format: '%e %B %Y').strip} - #{l(de, format: '%e %B %Y').strip}"
    end
  end

  # Elektas la eventkoloron
  def color_event(event)
    return 'purple' if event.online

    if event.date_end < Date.today # pasintaj eventoj estas grizaj
      'gray'
    else
      'green' # Venontaj eventoj estas verdaj
    end
  end

  def markdown(text)
    options = { hard_wrap: true, filter_html: true, autolink: true }
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, options)
    markdown.render(text).html_safe
  end

  def event_full_description(event)
    text = event_date(event)
    text += event.online ? ' (Reta evento)' : " (#{event.country.name} - #{event.city})"
    text += "<br/>#{event.description}"
    text
  end

  def rss_enclosure(xml, event)
    return unless event.uploads.attached?

    upload = event.uploads.first
    return unless upload.blob.image?

    thumb = upload.variant(resize: '150x150').processed
    xml.enclosure url: rails_representation_url(thumb), length: upload.byte_size / 10, type: upload.content_type
  end
end
