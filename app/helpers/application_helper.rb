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
    l(date, format: '%e-a de %B %Y')
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
    raw markdown.render(text)
  end
end
