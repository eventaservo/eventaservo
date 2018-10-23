module ApplicationHelper
  def toolbar_item(url, text, icon, color, html_options = {})
    link_to icon('fas', icon, text), url, html_options.merge(class: color)
  end

  def toolbar_back(url)
    link_to raw("<i class='fa fa-arrow-left'></i> Voltar"), url, class: 'btn btn-outline-secondary pull-right'
  end

  def page_title(title, subtext = nil)
    content_tag(:div, raw("<h3>#{title} <small>#{subtext}</small></h3>"), class: 'page-header')
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
    return false unless record.errors.any?
    return_html = "<div class='error-handling'>"
    return_html += "<h4>Erros foram encontrados neste formulário</h4>"
    return_html += '<ul>'

    record.errors.full_messages.each do |msg|
      return_html += "<li>#{msg}</li>"
    end

    return_html += '</ul></div>'

    raw return_html
  end

end
