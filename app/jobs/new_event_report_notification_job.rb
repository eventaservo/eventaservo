class NewEventReportNotificationJob < ApplicationJob
  queue_as :low

  def perform(report_id)
    return true if Rails.env.test? || Rails.env.development?

    report = Event::Report.find(report_id)
    return unless report

    message = "Nova raporto kreita de #{report.user.name}:\n\n"
    message += "<b>Ligilo: </b>#{report.url}\n"
    message += "<b>Titolo: </b>#{report.title}\n"
    message += "<b>Evento: </b><a href='#{event_url(report.event.code)}'>#{report.event.title}</a>\n"

    Telegram.send_message(message)
  end
end
