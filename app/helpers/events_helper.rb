module EventsHelper

  def event_like_button(event)
    return icon('fas', 'heart', event.likes.count) unless user_signed_in?
    button_class = current_user.liked?(event) ? 'button-like-pressed' : 'button-like'
    link_to content_tag(:span, event.likes.count, class: 'badge badge-primary'),
            event_toggle_like_path(event.code), class: button_class,
            data: { toggle: 'tooltip', placement: 'top' }, title: 'Ŝategi!'

  end

  def event_participant_button(event)
    return icon('fas', 'user-check', pluralize(event.participants.count, 'partoprenanto', 'partoprenantoj')) unless user_signed_in?
    button_class = current_user.participant?(event) ? 'button-participant-pressed' : 'button-participant'
    link_to content_tag(:span, event.participants.count, class: 'badge badge-success'),
            event_toggle_participant_path(event.code), class: button_class,
            data: { toggle: 'tooltip', placement: 'top' }, title: 'Partoprenantoj'
  end

  def event_keep_me_informed_button(event)
    return unless user_signed_in?
    button_class = current_user.follower?(event) ? 'button-informed-pressed' : 'button-informed'
    link_to 'Sciigu min', event_toggle_follow_path(event.code), class: button_class,
            data: { toggle: 'tooltip', placement: 'top' }, title: 'Sendu informojn al mi pri tiu evento'
  end

  def display_event_list_style_chooser
    content_tag(:div, class: 'text-center small') do
      concat link_to_unless session[:event_list_style] == 'listo', 'listo', view_style_path('listo')
      concat ' | '
      concat link_to_unless session[:event_list_style] == 'kartoj', 'kartoj', view_style_path('kartoj')
      concat ' | '
      concat link_to_unless session[:event_list_style] == 'kalendaro', 'kalendaro', view_style_path('kalendaro')
    end
  end

  def display_events_by_style
    case session[:event_list_style]
    when 'kartoj'
      render partial: 'events/events_as_cards', locals: { events: @events }
    when 'kalendaro'
      render partial: 'events/events_as_calendar', locals: { events: @events }
    else
      render partial: 'events/events_as_list', locals: { events: @events }
    end
  end
end
