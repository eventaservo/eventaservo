# frozen_string_literal: true

class SciigasUzantojnAntauEventoJob < ApplicationJob
  queue_as :event_reminders
  retry_on Postmark::TimeoutError, Net::OpenTimeout, wait: 1.minute, attempts: 5

  # reminder_date_string must be one of
  #   - "2.hours"
  #   - "1.week"
  #   - "1.month"
  def perform(event_id, reminder_date_string = "2.hours")
    event = Event.find_by(id: event_id)

    return unless event
    return if event.participants.empty?
    return if event.date_start < DateTime.now

    emails = event.participants_records.pluck(:email)
    emails.each do |email|
      EventMailer.rememorigas_uzantojn_pri_evento(event.id, email, reminder_date_string).deliver_later
    end
  rescue => e
    Sentry.capture_exception(e)
  end
end
