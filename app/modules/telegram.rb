# frozen_string_literal: true

module Telegram
  API_KEY = Rails.application.credentials.telegram_api_key
  CHAT_ID = "-1001277392976"

  def self.send_message(text)
    HTTParty.post("https://api.telegram.org/bot#{API_KEY}/sendMessage",
      headers: {
        "Content-Type": "application/json"
      },
      body: {
        parse_mode: "HTML",
        chat_id: CHAT_ID,
        text: text
      }.to_json)
  end
end
