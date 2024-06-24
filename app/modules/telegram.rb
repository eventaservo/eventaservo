# frozen_string_literal: true

module Telegram
  def self.send_message(text)
    HTTParty.post("https://api.telegram.org/bot#{::TELEGRAM_API_KEY}/sendMessage",
      headers: {
        "Content-Type": "application/json"
      },
      body: {
        parse_mode: "HTML",
        chat_id: TELEGRAM_CHAT_ID,
        text: text
      }.to_json)
  end
end
