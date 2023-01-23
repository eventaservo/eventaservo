# frozen_string_literal: true

class SciigasUzantojnAntauEventoJob < ApplicationJob
  queue_as :rememoriga_mesagho
  retry_on Postmark::TimeoutError, Net::OpenTimeout, wait: 1.minute, attempts: 5

  def perform(code, reminder_date_string = "2.hours")
    e = Event.by_code(code)
    return if e.blank?

    begin
      return unless e.participants.any?

      EventMailer.rememorigas_uzantojn_pri_evento(e.id, reminder_date_string).deliver_later
    rescue StandardError => e
      Sentry.capture_exception(e)
    end
  end
end
