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
      if session[:event_list_style] == 'kartoj'
        link_to 'Vidu kiel listo', view_style_path('listo')
      else
         link_to 'Vidu kiel kartoj', view_style_path('kartoj')
      end
    end
  end
end
