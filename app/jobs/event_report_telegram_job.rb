class EventReportTelegramJob < ApplicationJob
  queue_as :telegram

  # @params report_id [Integer] Event::Report id
  # @params action [Symbol] :create or :update or :destroy
  def perform(report_id, action)
    return true if Rails.env.test? || Rails.env.development?

    report = Event::Report.find(report_id)
    actions = {create: "kreita", update: "ĝisdatigita", destroy: "forigita"}

    text = <<~TEXT
      Eventa raporto #{actions[action]}

      <b>#{report.title}</b>
      Autoro: #{report.user.name}

      #{event_report_url(report.event.code, report)}
    TEXT

    Telegram.send_message(text)
  end
end
