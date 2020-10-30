class SciigasUzantojnAntauEventoJob < ApplicationJob
  queue_as :rememoriga_mesagho

  def perform(code)
    e = Event.by_code(code)
    return unless e.participants.any?

    EventMailer.rememorigas_uzantojn_pri_evento(e.id).deliver_later
  end
end
