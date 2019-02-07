module CalendarHelper
  def calendar_icon(date)
    content_tag(:time, class: 'icon', datetime: date.strftime('%Y-%m-%d')) do
      concat content_tag(:h2, l(date, format: '%Y'))
      concat content_tag(:em, l(date, format: '%A'))
      concat content_tag(:strong, l(date, format: '%B'))
      concat content_tag(:span, l(date, format: '%d'))
    end
  end
end
