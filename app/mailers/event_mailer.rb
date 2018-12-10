# frozen_string_literal: true

class EventMailer < ApplicationMailer
  add_template_helper ApplicationHelper
  require 'redcarpet/render_strip'

  def send_updates_to_followers(event)
    @event    = event
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)

    addresses = @event.followers.joins(:user).select('users.name, users.email').pluck(:email)

    mail(
      to: 'kontakto@eventaservo.org',
      bcc: addresses,
      subject: "Evento \"#{@event.title}\" ŝanĝita",
      reply_to: @event.user.email,
      content_type: :text
    )
  end

  def send_event_to_admin(event_id, update: false)
    @event = Event.find(event_id)
    event_action = update ? 'Ĝistadigita' : 'Nova'
    mail(
      to: 'kontakto@eventaservo.org',
      subject: "#{event_action} evento: #{@event.title}",
      content_type: :text
    )
  end

  def self.send_notification_to_users(event_id:)
    return false unless Event.exists?(event_id)
    return false unless Rails.env.production? # Ne sendas retmesaĝon dum provo

    event      = Event.includes(:country).find(event_id)
    recipients = event.country.recipients
    return false if recipients.empty?

    recipients.each do |recipient|
      notify_user(event_id, recipient.id).deliver_later
    end
  end

  def notify_user(event_id, recipient_id)
    @recipient = NotificationList.find(recipient_id)
    @event     = Event.includes(:country).find(event_id)
    mail(to: @recipient.email, subject: "Nova evento: #{@event.title}")
  end
end
