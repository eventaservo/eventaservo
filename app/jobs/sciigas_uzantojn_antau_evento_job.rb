class SciigasUzantojnAntauEventoJob < ApplicationJob
  queue_as :rememoriga_mesagho

  def perform(evento_id)
    e = Event.find(evento_id)
    return unless e.participants.any?

    emails = e.participants_records.pluck(:email)
    emails.each do |retadreso|
      EventMailer.rememorigas_uzantojn_pri_evento(evento_id, retadreso).deliver_later
    end
  end
end
