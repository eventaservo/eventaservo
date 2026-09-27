# frozen_string_literal: true

require "test_helper"

class HomeController::AnoncojTest < ActionDispatch::IntegrationTest
  test "renders the anoncoj page with events tagged as Anonco or Konkurso" do
    travel_to Time.zone.local(2026, 8, 10, 12, 0, 0) do
      event = create(:event,
        title: "Konferenco de Testo",
        date_start: Time.zone.local(2026, 9, 1, 10, 0, 0),
        date_end: Time.zone.local(2026, 9, 1, 18, 0, 0))
      event.tags << tags(:anonco)

      get anoncoj_url
      assert_response :success
      assert_match "Konferenco de Testo", response.body
    end
  end

  test "excludes events not tagged as Anonco or Konkurso" do
    travel_to Time.zone.local(2026, 8, 10, 12, 0, 0) do
      create(:event,
        title: "Nekonferenca Evento",
        date_start: Time.zone.local(2026, 9, 1, 10, 0, 0),
        date_end: Time.zone.local(2026, 9, 1, 18, 0, 0))

      get anoncoj_url
      assert_response :success
      assert_no_match "Nekonferenca Evento", response.body
    end
  end

  test "excludes deleted events tagged as Anonco" do
    travel_to Time.zone.local(2026, 8, 10, 12, 0, 0) do
      event = create(:event,
        title: "Forigita Konferenco",
        deleted: true,
        date_start: Time.zone.local(2026, 9, 1, 10, 0, 0),
        date_end: Time.zone.local(2026, 9, 1, 18, 0, 0))
      event.tags << tags(:anonco)

      get anoncoj_url
      assert_response :success
      assert_no_match "Forigita Konferenco", response.body
    end
  end
end
