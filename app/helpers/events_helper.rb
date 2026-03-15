# frozen_string_literal: true

module EventsHelper
  # Renders the appropriate events partial based on the +vidmaniero+ cookie.
  #
  # Dispatches to:
  # - +events/events_calendar+ when cookie is +"kalendaro"+ (requires calendar assigns
  #   prepared by {CalendarData#prepare_calendar_data})
  # - +events/events_as_map+ when cookie is +"mapo"+
  # - +events/events_as_cards+ for all other values
  #
  # @return [String] rendered HTML partial
  def display_events_by_style
    case cookies[:vidmaniero]
    when "kalendaro"
      render partial: "events/events_calendar", locals: {
        date: @calendar_date,
        today_path: @calendar_today_path,
        prev_path: @calendar_prev_path,
        next_path: @calendar_next_path,
        events_by_day: @events_by_day
      }
    when "mapo"
      render partial: "events/events_as_map", locals: {events: @today_events.order(:date_start) + @events.order(:date_start)}
    else
      render partial: "events/events_as_cards", locals: {events: @events}
    end
  end

  def event_flag(event)
    return unless event.country.code
    return if event.organizations.any? { |o| o.display_flag == false }

    flag = flag_icon(event.country.code)
    if event.universala?
      "🖥 "
    elsif event.online
      flag + " 🖥 "
    else
      flag
    end
  end

  def event_map_url(event)
    "https://www.google.com/maps/search/?api=1&query=#{event.full_address}"
  end

  def days_to_event(event)
    if event.date_start < Time.zone.today && event.date_end >= Time.zone.today
      0
    else
      Integer(event.date_start.to_date - Time.zone.today)
    end
  end

  def event_map_pin_color(event)
    return "redIcon" if event.cancelled

    case days_to_event(event)
    when -30..0 then "greenIcon"
    when 1..7 then "orangeIcon"
    when 8..30 then "yellowIcon"
    else "blueIcon"
    end
  end

  def event_color_class(event)
    case days_to_event(event)
    when 0 then "event-color-today"
    when 1..7 then "event-color-7days"
    when 8..30 then "event-color-30days"
    when 31..Float::INFINITY then "event-color-future"
    else "event-color-past"
    end
  end

  # Protektas la retadreson kontaŭ spamoj
  def display_event_email(event)
    if user_signed_in?
      mail_to(event.email, event.email, subject: "Informoj pri la evento #{event.title}", class: "button-contact")
    else
      event.email.gsub("@", " <ĉe> ").gsub(".", " <punkto> ")
    end
  end

  def link_to_event_count(periodo, organizo, speco, &_block)
    active_class =
      if params[:periodo].present?
        (params[:periodo] == periodo) ? "ec-active" : "ec-inactive"
      end

    link_to url_for(periodo: (periodo unless params[:periodo] == periodo), o: organizo, s: speco),
      class: "event-count #{periodo} #{active_class}" do
      yield
    end
  end

  def speconomo_plurale(tag)
    case tag
    when "Kunveno/Evento" then "Kunvenoj/Eventoj"
    when "Kurso" then "Kursoj"
    when "Alia" then "Aliaj"
    else tag
    end
  end
end
