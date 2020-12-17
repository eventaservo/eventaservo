class SciigasUzantojnAntauEventoJob < ApplicationJob
  queue_as :rememoriga_mesagho

  def perform(code)
    e = Event.by_code(code)

    unless e.participants.any?
      logger.info "[INFO] Evento #{code} ne havas partoprenontoj. Rememoriga mesaĝo ne sendita."
      return
    end

    logger.info "[INFO] Partoprenontoj de evento #{code} trovita. Sendante rememorigan mesaĝon."
    EventMailer.rememorigas_uzantojn_pri_evento(e.id).deliver_later
  end
end
