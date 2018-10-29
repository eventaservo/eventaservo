module EventsHelper

  def event_like_button(event)
    return icon('fas', 'heart', event.likes.count) unless user_signed_in?
    button_class = current_user.liked?(event) ? 'button-like-pressed' : 'button-like'
    link_to content_tag(:span, event.likes.count, class: 'badge badge-primary'),
            event_toggle_like_path(event.code), class: button_class
  end

  def event_participant_button(event)
    return icon('fas', 'user-check', event.participants.count) unless user_signed_in?
    button_class = current_user.participant?(event) ? 'button-participant-pressed' : 'button-participant'
    link_to content_tag(:span, event.participants.count, class: 'badge badge-success'),
            event_toggle_participant_path(event.code), class: button_class
  end

  def event_keep_me_informed_button(event)
    return unless user_signed_in?
    button_class = current_user.follower?(event) ? 'button-informed-pressed' : 'button-informed'
    link_to 'Sciigu min', event_toggle_follow_path(event.code), class: button_class
  end
end
