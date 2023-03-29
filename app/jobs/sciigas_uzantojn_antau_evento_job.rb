# frozen_string_literal: true

class SciigasUzantojnAntauEventoJob < ApplicationJob
  queue_as :rememoriga_mesagho
  retry_on Postmark::TimeoutError, Net::OpenTimeout, wait: 1.minute, attempts: 5

  def perform(code, reminder_date_string = "2.hours")
    event = Event.by_code(code)

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
