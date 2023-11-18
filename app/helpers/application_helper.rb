# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def page_title(title, subtext = nil)
    content_tag(:h2, class: "text-center") do
      concat title
      concat content_tag(:small, " " + subtext) if subtext
    end
  end

  def flash_class(level)
    case level
    when :notice then "alert alert-primary alert-dismissible"
    when :success then "alert alert-success alert-dismissible"
    when :error then "alert alert-danger alert-dismissible"
    when :alert then "alert alert-warning alert-dismissible"
    else "alert alert-info alert-dismissible"
    end
  end

  def error_handling(record)
    return unless record.errors.any?

    return_html = "<div class='error-handling'>"
    return_html += "<h5>Troviĝas eraro en la formularo</h5>"
    return_html += "<ul>"

    record.errors.full_messages.each do |msg|
      return_html += "<li>#{msg}</li>"
    end

    return_html += "</ul></div>"

    raw return_html
  end

  # Stiloj:
  #   default   = 1-a de Januaru de 2019
  #   :short    = 01/Jan/19
  def format_date(date, style: nil)
    case style
    when :short then l(date, format: "%e/%b/%y").strip
    when :month_year then l(date, format: "%B %Y").strip
    else l(date, format: "%A, %e %B %Y").strip
    end
  end

  # Simpligas la eventajn datojn
  def event_date(event)
    ds = event.komenca_dato
    de = event.fina_dato
    return format_date(ds) if event.samtaga?

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
    return "red" if event.cancelled
    return "purple" if event.online

    if event.date_end < Time.zone.today # pasintaj eventoj estas grizaj
      "gray"
    else
      "green" # Venontaj eventoj estas verdaj
    end
  end

  def markdown(text)
    options = { hard_wrap: true, filter_html: true, autolink: true }
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, options)
    markdown.render(text).html_safe
  end

  def event_full_description(event)
    text = event_date(event)
    text += event.online ? " (Reta evento)" : " (#{event.country.name} - #{event.city})"
    text += "<br/>#{event.description}"
  end

  def rss_enclosure(xml, event)
    return unless event.uploads.attached?

    upload = event.uploads.first
    return unless upload.blob.image?

    begin
      thumb = upload.variant(resize_to_limit: [150, 150]).processed
      xml.enclosure url: rails_representation_url(thumb), length: upload.byte_size / 10, type: upload.content_type
    rescue => e
      Sentry.capture_exception(e)
    end
  end

  def montras_flagon(lando)
    return if lando.nil?
    flag_icon(lando.code)
  end

  # Protektas la retadreson kontaŭ spamoj
  def montras_retposhtadreson(retposhtadreso)
    return if retposhtadreso.blank?

    if user_signed_in?
      icon("fas", "at", retposhtadreso, class: "copy-to-clipboard", data: { clipboard: retposhtadreso })
    else
      icon("fas", "at", retposhtadreso.gsub("@", "(ĉe)"))
    end
  end

  def montras_telefonnumeron(phone)
    return if phone.blank?

    icon("fas", "phone", class: "fg-color-link mr-1") + link_to(phone, "tel:#{phone}")
  end

  def montras_retpaghon(url)
    return if url.blank?

    text = url.length > 40 ? url[0..40] + "..." : url
    text = text.gsub(%r{http[s]?://}, "")
    icon("fas", "globe", class: "fg-color-link mr-1") + link_to(text, url, target: :_blank)
  end

  def montras_adreson(adreso, text: adreso)
    icon("fas", "map-marker-alt fg-color-link mr-1") +
      link_to(text, "https://www.google.com/maps/search/?api=1&query=#{adreso}", target: :_blank)
  end

  def article_link(text, link, description)
    content_tag(:p) do
      content_tag(:a, text, href: link, target: :_blank) +
        content_tag(:span, " #{description}", class: "small")
    end
  end
end
