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

  def format_date(date)
    l(date, format: '%e-a de %B %Y').strip
  end

  # Montras la eventan daton simple
  # Ekz: 17-21 de julio 2018
  def event_date(event)
    ds = event.date_start
    de = event.date_end
    return format_date(ds) if ds == de # Samtaga

    if de.year == ds.year # Samjara
      if de.month == ds.month # Sammonata
        "#{ds.day}-#{de.day} #{l(de, format: 'de %B %Y')}"
      else # malsammonata
        "#{l(ds, format: '%e-a de %B')} - #{l(de, format: '%e-a de %B %Y')}"
      end
    else # malsamjara
      "#{format_date(ds)} - #{format_date(de)}"
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
end
