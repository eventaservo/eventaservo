# frozen_string_literal: true

class EventMailer < ApplicationMailer
  helper ApplicationHelper
  helper EventsHelper

  default from: "kontakto@eventaservo.org"

  require "redcarpet/render_strip"

  def notify_admins(event_id, ghisdatigho: false)
    return false if Rails.env.development?

    @event = Event.find(event_id)
    if ghisdatigho
      subject = "[ES estraro] Ĝisdatiĝo: #{@event.title}"
      to = "yves.nevelsteen@gmail.com"
    else
      subject = "[ES estraro] Nova evento: #{@event.title}"
      to = Constants::ADMIN_EMAILS
    end
    mail(to: to, subject: subject)
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
    mail(to: "#{user.name.delete(",")} <#{user.email}>", subject: "Tutmonda semajna resumo de eventoj")
  end

  # Sends message to event owner
  #
  # @param event [Event]
  # @param user [User]
  # @param message [String] The message to send to the owner
  def kontakti_organizanton(event:, user:, message:)
    @event = event
    @user = user
    @message = message

    if Rails.env.production?
      to = @event.user.email
      bcc = "yves.nevelsteen@gmail.com"
    else
      to = Constants::ADMIN_EMAILS
      bcc = nil
    end

    mail(
      to:,
      bcc:,
      reply_to: @user.email,
      subject: "Informo pri via evento en Eventa Servo",
      track_opens: "true"
    )
  end

  def nova_administranto(evento)
    @evento = evento

    if Rails.env.production?
      to = evento.user.email
      bcc = "yves.nevelsteen@gmail.com"
    else
      to = Constants::ADMIN_EMAILS
      bcc = nil
    end

    mail(to: to, bcc: bcc, subject: "Vi estas nova eventa administranto")
  end

  def rememorigas_uzantojn_pri_evento(event_id, email, reminder_date_string)
    @event = Event.find_by(id: event_id)
    return if @event.nil?
    return if @event.date_start < DateTime.now

    @reminder_message = event_reminder_message(reminder_date_string)
    email_subject = reminder_email_subject(@event.title, reminder_date_string)

    mail(to: email,
      from: "Eventa Servo <kontakto@eventaservo.org>",
      subject: email_subject,
      track_opens: "true")

    Logs::Create.call(
      text: "Sent #{reminder_date_string} reminder message for event #{@event.title} to #{email}",
      user: User.system_account,
      loggable: @event,
      metadata: {reminder: reminder_date_string, email: email}
    )
  end

  private

  def event_reminder_message(reminder_date_string)
    hash = {
      "2.hours": "Ĝi komenciĝos baldaŭ. Ni deziras al vi agrablan kaj sukcesan partoprenon.",
      "1.week": "Ĝi komenciĝos post semajno. Pripensu aliĝi aŭ almenaŭ informi la organizanton de la evento pri via " \
                "intenco ĝin ĉeesti.",
      "1.month": "Ĝi komenciĝos post monato. Pripensu aliĝi aŭ almenaŭ informi la organizanton de la evento pri via " \
                 "intenco ĝin ĉeesti."
    }

    hash[reminder_date_string.to_sym]
  end

  def reminder_email_subject(title, reminder_date_string)
    hash = {
      "2.hours": "[ES] #{title} baldaŭ komenciĝos",
      "1.week": "[ES] #{title} komenciĝos post semajno",
      "1.month": "[ES] #{title} komenciĝos post monato"
    }

    hash[reminder_date_string.to_sym]
  end
end
