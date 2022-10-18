# frozen_string_literal: true

class SciigasUzantojnAntauEventoJob < ApplicationJob
  queue_as :rememoriga_mesagho

  def perform(code, reminder_date_string = "2.hours")
    e = Event.by_code(code)

    begin
      return unless e.participants.any?
    rescue StandardError => e
      Sentry.capture_exception(e)
    end

    EventMailer.rememorigas_uzantojn_pri_evento(e.id, reminder_date_string).deliver_later
  end
end
