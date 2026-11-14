# frozen_string_literal: true

module EventsHelper
  # Renders the appropriate events partial based on the +vidmaniero+ cookie.
  #
  # Dispatches to:
  # - +events/events_calendar+ when cookie is +"kalendaro"+ (requires calendar assigns
  #   prepared by {CalendarData#prepare_calendar_data}, including +@calendar_month_navigation_options+)
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
        month_navigation_options: @calendar_month_navigation_options,
        events_by_day: @events_by_day
      }
    when "mapo"
      render partial: "events/events_as_map", locals: {events: @today_events.order(:date_start) + @events.order(:date_start)}
    else
      render partial: "events/events_as_cards", locals: {events: @events}
    end
  end

  # URL of the past-events view for the current by-city, by-country or by-continent listing.
  #
  # @return [String, nil] the past-events URL, or nil when the page is not a geographic listing
  def past_events_listing_path
    if params[:city_name].present?
      events_by_city_path(continent: params[:continent], country_name: params[:country_name], city_name: params[:city_name], pasintaj: 1)
    elsif params[:country_name].present?
      events_by_country_path(continent: params[:continent], country_name: params[:country_name], pasintaj: 1)
    elsif params[:continent].present?
      events_by_continent_path(continent: params[:continent], pasintaj: 1)
    end
  end

  # URL of the upcoming-events view for the current by-city, by-country or by-continent listing.
  #
  # @return [String, nil] the upcoming-events URL, or nil when the page is not a geographic listing
  def upcoming_events_listing_path
    if params[:city_name].present?
      events_by_city_path(continent: params[:continent], country_name: params[:country_name], city_name: params[:city_name])
    elsif params[:country_name].present?
      events_by_country_path(continent: params[:continent], country_name: params[:country_name])
    elsif params[:continent].present?
      events_by_continent_path(continent: params[:continent])
    end
  end

  # Whether the listing is rendered as event cards (the default view mode).
  #
  # @return [Boolean]
  def cards_view_mode?
    %w[mapo kalendaro].exclude?(cookies[:vidmaniero])
  end

  # Whether the event belongs to a nearby city rather than the page's city.
  #
  # Only meaningful on the by-city page, where +@nearby_cities+ is assigned and
  # the card list may contain events from the target city plus nearby cities.
  #
  # @param event [Event]
  #
  # @return [Boolean]
  def event_nearby?(event)
    return false if @nearby_cities.blank? || params[:city_name].blank? || @country.nil?

    event.country_id != @country.id || event.city.to_s.normalized != params[:city_name].normalized
  end

  # Path to the nearby-cookie toggle route.
  #
  # Routes to +/nearby/off+ when nearby events are currently shown (to hide
  # them) and to +/nearby/on+ when they are hidden (to show them again).
  #
  # @param include_nearby [Boolean] whether nearby events are currently shown
  #
  # @return [String]
  def nearby_toggle_link_path(include_nearby:)
    nearby_toggle_path(state: include_nearby ? "off" : "on")
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

  EVENT_BORDER_CLASSES = {
    today: "tw:border-l-[3px] tw:border-l-event-today",
    soon: "tw:border-l-[3px] tw:border-l-event-7days",
    later: "tw:border-l-[3px] tw:border-l-event-30days",
    future: "tw:border-l-[3px] tw:border-l-event-future",
    past: "tw:border-l-[3px] tw:border-l-event-past"
  }.freeze

  def event_color_class(event)
    case days_to_event(event)
    when 0 then "event-color-today"
    when 1..7 then "event-color-7days"
    when 8..30 then "event-color-30days"
    when 31..Float::INFINITY then "event-color-future"
    else "event-color-past"
    end
  end

  # Returns the Tailwind left-border utility classes indicating how soon an event occurs.
  #
  # @param event [Event] the event to style
  #
  # @return [String] Tailwind border width and color classes
  def event_border_color_class(event)
    case days_to_event(event)
    when 0 then EVENT_BORDER_CLASSES[:today]
    when 1..7 then EVENT_BORDER_CLASSES[:soon]
    when 8..30 then EVENT_BORDER_CLASSES[:later]
    when 31..Float::INFINITY then EVENT_BORDER_CLASSES[:future]
    else EVENT_BORDER_CLASSES[:past]
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

  TAG_PLURAL_I18N_KEYS = {
    "Kunveno/Evento" => "tags.plural.kunveno_evento",
    "Kurso" => "tags.plural.kurso",
    "Alia" => "tags.plural.alia",
    "Anonco" => "tags.plural.anonco",
    "Konkurso" => "tags.plural.konkurso",
    "Por junuloj" => "tags.plural.por_junuloj",
    "Unutaga" => "tags.plural.unutaga",
    "Plurtaga" => "tags.plural.plurtaga"
  }.freeze

  TAG_SINGULAR_I18N_KEYS = {
    "Kunveno/Evento" => "tags.singular.kunveno_evento",
    "Kurso" => "tags.singular.kurso",
    "Alia" => "tags.singular.alia",
    "Anonco" => "tags.singular.anonco",
    "Konkurso" => "tags.singular.konkurso",
    "Por junuloj" => "tags.singular.por_junuloj",
    "Unutaga" => "tags.singular.unutaga",
    "Plurtaga" => "tags.singular.plurtaga"
  }.freeze

  # Returns the plural display name of a tag.
  #
  # Some tag names have an Esperanto plural form that differs from the singular
  # name stored in the database, so tag badges are rendered in the plural
  # (e.g. "Kunvenoj/Eventoj" instead of "Kunveno/Evento"). Names without a
  # known plural are returned unchanged.
  #
  # @param tag_name [String] the singular tag name
  #
  # @return [String] the plural tag name, or the given name when it has no known plural
  def tag_plural_name(tag_name)
    key = TAG_PLURAL_I18N_KEYS[tag_name]
    key ? I18n.t(key) : tag_name
  end

  # Returns the localized singular display name of a tag.
  #
  # @param tag_or_name [Tag, String, nil] the tag instance or singular tag name
  #
  # @return [String] the localized singular tag name, or the given name when untranslated
  def tag_display_name(tag_or_name)
    return "" if tag_or_name.nil?

    name = tag_or_name.is_a?(Tag) ? tag_or_name.name : tag_or_name.to_s
    key = TAG_SINGULAR_I18N_KEYS[name]
    key ? I18n.t(key) : name
  end
end
