# frozen_string_literal: true

class EventMailer < ApplicationMailer
  add_template_helper ApplicationHelper
  add_template_helper EventsHelper

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

  def self.send_notification_to_users(event_id:)
    return false unless Event.exists?(event_id)
    return false unless Rails.env.production? # Ne sendas retmesaĝon dum provo

    event      = Event.includes(:country).find(event_id)
    recipients = event.country.recipients
    recipients += NotificationList.admins
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

  def self.send_weekly_summary_to_users
    User.receives_weekly_summary.each do |user|
      EventMailer.weekly_summary(user).deliver_later
    end
  end

  def weekly_summary(user)
    @events = Event.by_dates(from: Time.zone.today, to: Time.zone.today + 7.days)
    # @user = user
    @user = User.find(1) # Nur por provoj
    mail(to: "#{user.name.delete(',')} <#{user.email}>", subject: 'Tutmonda semajna resumo de eventoj')
  end

  def kontakti_organizanton(eventa_kodo, informoj = {})
    @evento = Event.by_code(eventa_kodo)
    @informoj = informoj
    mail(to: 'Eventa Servo <kontakto@eventaservo.org>, Yves Nevelsteen <yves.nevelsteen@gmail.com>', subject: 'Informo pri via evento en Eventa Servo')
  end
end
