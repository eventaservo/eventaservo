# frozen_string_literal: true

require "test_helper"

class HomeController::EventsTest < ActionDispatch::IntegrationTest
  test "renders regular events as JSON for the calendar feed" do
    travel_to Time.zone.parse("2026-07-01 12:00:00") do
      create(
        :event,
        title: "Kurso de Esperanto",
        date_start: Time.zone.parse("2026-07-10 10:00:00"),
        date_end: Time.zone.parse("2026-07-10 12:00:00")
      )

      get "/events.json", params: {start: "2026-06-01", end: "2026-08-01"}, headers: {"SERVER_NAME" => "localhost"}

      assert_response :success
      assert_equal "application/json", response.media_type

      feed = response.parsed_body
      assert feed.is_a?(Array)
      assert feed.pluck("title").any? { |title| title.include?("Kurso de Esperanto") }
    end
  end
end
