# frozen_string_literal: true

module ApplicationHelper
  # Font Awesome icon helper — replicates font-awesome-sass gem's icon() method.
  # Generates <i class="STYLE fa-NAME" aria-hidden="true"></i> followed by optional text.
  def icon(style, name, text = nil, html_options = {})
    text, html_options = nil, text if text.is_a?(Hash)

    content_class = "#{style} fa-#{name}"
    content_class << " #{html_options[:class]}" if html_options.key?(:class)
    html_options[:class] = content_class
    html_options["aria-hidden"] ||= true

    html = content_tag(:i, nil, html_options)
    html << " " << text.to_s unless text.blank?
    html
  end

  def page_title(title, subtext = nil)
    content_tag(:h2, class: "text-center") do
      concat title
      concat content_tag(:small, " " + subtext) if subtext
    end
  end

  def flash_class(level)
    case level
    when :notice then "alert-primary"
    when :success then "alert-success"
    when :error then "alert-danger"
    when :alert then "alert-warning"
    else "alert-info"
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

  # Formats a date according to the given style.
  #
  # @param date [Date, Time, DateTime] the date to format
  # @param style [Symbol, nil] the format style (:short, :compact, :month_year, or nil for default)
  # @return [String] the formatted date string
  #
  # @example Default style
  #   format_date(Date.new(2026, 3, 8)) #=> "Dimanĉo, 8 Marto 2026"
  #
  # @example Short style
  #   format_date(Date.new(2026, 3, 8), style: :short) #=> " 8/Mar/26"
  #
  # @example Compact style
  #   format_date(Date.new(2026, 3, 8), style: :compact) #=> "8 MAR 26"
  #
  # @example Month/year style
  #   format_date(Date.new(2026, 3, 8), style: :month_year) #=> "Marto 2026"
  def format_date(date, style: nil)
    case style
    when :short then l(date, format: "%e/%b/%y").strip
    when :compact then l(date, format: "%e %b %y").strip.upcase
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
        "#{ds.day} - #{de.day} #{l(de, format: "%B %Y")}"
      else # malsammonata
        "#{l(ds, format: "%e %B")} - #{l(de, format: "%e %B %Y")}"
      end
    else # malsamjara
      "#{l(ds, format: "%e %B %Y").strip} - #{l(de, format: "%e %B %Y").strip}"
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
    options = {hard_wrap: true, filter_html: true, autolink: true}
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, options)
    markdown.render(text).html_safe
  end

  def event_full_description(event)
    text = event_date(event)
    text += event.online ? " (Reta evento)" : " (#{event.country.name} - #{event.city})"
    text += "<br/>#{event.description}"

    text
  end

  def rss_enclosure(xml, event)
    return unless event.uploads.attached?

    upload = event.uploads.first
    return unless upload.blob.image?

    begin
      thumb = upload.variant(resize_to_limit: [150, 150]).processed
      xml.enclosure url: rails_storage_proxy_url(thumb), length: upload.byte_size / 10, type: upload.content_type
    rescue => e
      Sentry.capture_exception(e)
    end
  end

  # Renders a country flag icon as an inline span element using the flag-icons npm package.
  #
  # @example Rectangular flag
  #   flag_icon("br")
  #   # => <span class="fi fi-br"></span>
  #
  # @example Squared flag
  #   flag_icon(:gb, squared: true)
  #   # => <span class="fi fi-gb fis"></span>
  #
  # @param country_code [String, Symbol] ISO 3166-1 alpha-2 country code (e.g. "br", :gb)
  # @param squared [Boolean] whether to render the squared (1x1) variant; defaults to false
  #
  # @return [ActiveSupport::SafeBuffer] HTML span with the appropriate flag-icons CSS classes
  def flag_icon(country_code, squared: false)
    classes = ["fi", "fi-#{country_code.to_s.downcase}"]
    classes << "fis" if squared
    content_tag(:span, nil, class: classes.join(" "))
  end

  # Renders the flag icon for a country object (Esperanto: montras flagon).
  #
  # @param lando [Country, nil] a country object responding to `#code`
  #
  # @return [ActiveSupport::SafeBuffer, nil] flag icon HTML, or nil if lando is nil
  def montras_flagon(lando)
    return if lando.nil?
    flag_icon(lando.code)
  end

  # Protektas la retadreson kontaŭ spamoj
  def montras_retposhtadreson(retposhtadreso)
    return if retposhtadreso.blank?

    if user_signed_in?
      icon("fas", "at", retposhtadreso, data: {controller: "clipboard", clipboard_text_value: retposhtadreso, action: "click->clipboard#copy"})
    else
      icon("fas", "at", retposhtadreso.gsub("@", "(ĉe)"))
    end
  end

  def montras_telefonnumeron(phone)
    return if phone.blank?

    icon("fas", "phone", class: "fg-color-link me-1") + link_to(phone, "tel:#{phone}")
  end

  def montras_retpaghon(url)
    return if url.blank?

    text = (url.length > 40) ? url[0..40] + "..." : url
    text = text.gsub(%r{https?://}, "")
    icon("fas", "globe", class: "fg-color-link me-1") + link_to(text, url, target: :_blank)
  end

  def montras_adreson(adreso, text: adreso)
    icon("fas", "map-marker-alt fg-color-link me-1") +
      link_to(text, "https://www.google.com/maps/search/?api=1&query=#{adreso}", target: :_blank)
  end

  def article_link(text, link, description)
    content_tag(:p) do
      content_tag(:a, text, href: link, target: :_blank) +
        content_tag(:span, " #{description}", class: "small")
    end
  end
end
