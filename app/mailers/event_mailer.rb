# frozen_string_literal: true

# Mailer responsible for dispatching transactional event emails, including
# weekly summaries, organizer contact notifications, new admin assignment alerts,
# and upcoming event reminder notifications.
class EventMailer < ApplicationMailer
  helper ApplicationHelper
  helper EventsHelper

  default from: "kontakto@eventaservo.org"

  require "redcarpet/render_strip"

  # Sends notification to system administrators or board regarding new or updated events.
  #
  # @param event_id [Integer] ID of the event
  # @param ghisdatigho [Boolean] Whether this notification is for an event update
  # @param locale [Symbol, String, nil] Optional locale to render the email in
  # @return [ActionMailer::MessageDelivery, Boolean] False in development, mail object otherwise
  def notify_admins(event_id, ghisdatigho: false, locale: nil)
    return false if Rails.env.development?

    @event = Event.find(event_id)
    target_locale = resolve_locale_for(nil, locale)

    I18n.with_locale(target_locale) do
      if ghisdatigho
        subject = I18n.t("event_mailer.notify_admins.subject_update", title: @event.title)
        to = "yves.nevelsteen@gmail.com"
      else
        subject = I18n.t("event_mailer.notify_admins.subject_new", title: @event.title)
        to = Constants::ADMIN_EMAILS
      end
      mail(to: to, subject: subject)
    end
  end

  # Sends weekly event summary emails to all subscribed users.
  #
  # @return [Array<ActionMailer::MessageDelivery>]
  def self.send_weekly_summary_to_users
    User.receives_weekly_summary.each do |user|
      EventMailer.weekly_summary(user).deliver_later
    end
  end

  # Renders and delivers a weekly summary of upcoming events to a user.
  #
  # @param user [User] The recipient user
  # @param locale [Symbol, String, nil] Optional locale to render the email in
  # @return [ActionMailer::MessageDelivery]
  def weekly_summary(user, locale: nil)
    @user = user
    @events = Event.by_dates(from: Time.zone.today, to: Time.zone.today + 7.days)
    target_locale = resolve_locale_for(user, locale)

    I18n.with_locale(target_locale) do
      mail(to: "#{user.name.delete(",")} <#{user.email}>", subject: I18n.t("event_mailer.weekly_summary.subject"))
    end
  end

  # Sends a user message or problem report to the event organizer.
  #
  # @param event [Event] The event being inquired about
  # @param user [User] The user sending the message
  # @param message [String] The inquiry or report message content
  # @param locale [Symbol, String, nil] Optional locale to render the email in
  # @return [ActionMailer::MessageDelivery]
  def kontakti_organizanton(event:, user:, message:, locale: nil)
    @event = event
    @user = user
    @message = message

    target_locale = resolve_locale_for(@event.user, locale)

    if Rails.env.production?
      to = @event.user.email
      bcc = "yves.nevelsteen@gmail.com"
    else
      to = Constants::ADMIN_EMAILS
      bcc = nil
    end

    I18n.with_locale(target_locale) do
      mail(
        to:,
        bcc:,
        reply_to: @user.email,
        subject: I18n.t("event_mailer.kontakti_organizanton.subject"),
        track_opens: "true"
      )
    end
  end

  # Notifies a user that they have been assigned as an administrator of an event.
  #
  # @param evento [Event] The event assigned to the user
  # @param locale [Symbol, String, nil] Optional locale to render the email in
  # @return [ActionMailer::MessageDelivery]
  def nova_administranto(evento, locale: nil)
    @evento = evento
    target_locale = resolve_locale_for(evento.user, locale)

    if Rails.env.production?
      to = evento.user.email
      bcc = "yves.nevelsteen@gmail.com"
    else
      to = Constants::ADMIN_EMAILS
      bcc = nil
    end

    I18n.with_locale(target_locale) do
      mail(to: to, bcc: bcc, subject: I18n.t("event_mailer.nova_administranto.subject"))
    end
  end

  # Sends a reminder email to an interested participant prior to the start of an event.
  #
  # @param event_id [Integer] ID of the upcoming event
  # @param email [String] Email address of the participant
  # @param reminder_date_string [String] Interval identifier ("2.hours", "1.week", "1.month")
  # @param locale [Symbol, String, nil] Optional locale to render the email in
  # @return [ActionMailer::MessageDelivery, nil]
  def rememorigas_uzantojn_pri_evento(event_id, email, reminder_date_string, locale: nil)
    @event = Event.find_by(id: event_id)
    return if @event.nil?
    return if @event.date_start < DateTime.now

    target_locale = resolve_locale_for(email, locale)

    I18n.with_locale(target_locale) do
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
  end

  private

  # Resolves the effective locale for a recipient, falling back to default locale (:eo).
  #
  # @param recipient [User, String, nil] The recipient user or email
  # @param explicit_locale [Symbol, String, nil] Explicitly provided locale
  # @return [Symbol]
  def resolve_locale_for(recipient, explicit_locale = nil)
    return explicit_locale.to_sym if explicit_locale.present? && I18n.available_locales.include?(explicit_locale.to_sym)

    if recipient.respond_to?(:preferred_locale)
      recipient.preferred_locale
    elsif recipient.is_a?(String)
      user = User.find_by(email: recipient)
      user&.preferred_locale || I18n.default_locale
    else
      I18n.default_locale
    end
  end

  # Formats the localized reminder message body for an upcoming event.
  #
  # @param reminder_date_string [String] Interval identifier ("2.hours", "1.week", "1.month")
  # @return [String]
  def event_reminder_message(reminder_date_string)
    key = reminder_key(reminder_date_string)
    I18n.t("event_mailer.reminders.messages.#{key}")
  end

  # Formats the localized reminder email subject for an upcoming event.
  #
  # @param title [String] Event title
  # @param reminder_date_string [String] Interval identifier ("2.hours", "1.week", "1.month")
  # @return [String]
  def reminder_email_subject(title, reminder_date_string)
    key = reminder_key(reminder_date_string)
    I18n.t("event_mailer.reminders.subjects.#{key}", title: title)
  end

  # Normalizes a reminder interval string into an i18n translation key segment.
  #
  # @param reminder_date_string [String] Interval identifier (e.g., "2.hours")
  # @return [String] Normalized segment (e.g., "hours_2")
  def reminder_key(reminder_date_string)
    case reminder_date_string.to_s
    when "2.hours" then "hours_2"
    when "1.week" then "week_1"
    when "1.month" then "month_1"
    else reminder_date_string.to_s.tr(".", "_")
    end
  end
end
