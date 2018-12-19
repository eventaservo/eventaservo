# frozen_string_literal: true

module EventsHelper
  def event_like_button(event)
    return icon('fas', 'heart', event.likes.count) unless user_signed_in?

    button_class = current_user.liked?(event) ? 'button-like-pressed' : 'button-like'
    link_to event.likes.count, event_toggle_like_path(event.code), class: button_class
  end

  def event_participant_button(event)
    return icon('fas', 'user-check', pluralize(event.participants.count, 'partoprenanto', 'partoprenantoj')) unless user_signed_in?

    button_class = current_user.participant?(event) ? 'button-participant-pressed' : 'button-participant'
    link_to event.participants.count, event_toggle_participant_path(event.code), class: button_class
  end

  def display_events_by_style
    case session[:event_list_style]
    when 'kartoj'
      render partial: 'events/events_as_cards', locals: { events: @events }
    when 'kalendaro'
      render partial: 'events/events_as_calendar', locals: { events: @events }
    when 'mapo'
      render partial: 'events/events_as_map', locals: {events: @events }
    else
      render partial: 'events/events_as_list', locals: { events: @events }
    end
  end

  def event_flag(event)
    return unless event.country.code

    flag_icon(event.country.code)
  end

  def event_map_url(event)
    "https://www.google.com/maps/search/?api=1&query=#{event.full_address}"
  end

  def days_to_event(event)
    Integer(event.date_start.to_date - Date.today)
  end

  def event_map_pin_color(event)
    case days_to_event(event)
    when -30..0 then 'greenIcon'
    when 1..7 then 'yellowIcon'
    when 8..30 then 'orangeIcon'
    else 'blueIcon'
    end
  end
end
