# frozen_string_literal: true

require "test_helper"

class HomeController::SearchTest < ActionDispatch::IntegrationTest
  test "lists upcoming events closest first" do
    travel_to Time.zone.local(2026, 11, 10, 12, 0, 0) do
      create(:event, title: "Zamenhofa kongreso en Pizo", date_start: Time.zone.local(2027, 12, 28, 10, 0, 0))
      create(:event, title: "Zamenhofa festo en Vieno", date_start: Time.zone.local(2026, 12, 12, 10, 0, 0))

      get serchilo_url(query: "Zamenhof")

      assert_response :success
      assert_operator body_index("Zamenhofa festo en Vieno"), :<, body_index("Zamenhofa kongreso en Pizo")
    end
  end

  test "lists the most recent past events first when pasintaj is enabled" do
    travel_to Time.zone.local(2026, 11, 10, 12, 0, 0) do
      create(:event, title: "Zamenhofa festo de 2025", date_start: Time.zone.local(2025, 12, 13, 10, 0, 0))
      create(:event, title: "Zamenhofa festo de oktobro", date_start: Time.zone.local(2026, 10, 1, 10, 0, 0))

      get serchilo_url(query: "Zamenhof", pasintaj: true)

      assert_response :success
      assert_operator body_index("Zamenhofa festo de oktobro"), :<, body_index("Zamenhofa festo de 2025")
    end
  end

  test "filters events by the to date" do
    travel_to Time.zone.local(2026, 11, 10, 12, 0, 0) do
      create(:event, title: "Zamenhofa festo en decembro", date_start: Time.zone.local(2026, 12, 13, 10, 0, 0))
      create(:event, title: "Zamenhofa festo en januaro", date_start: Time.zone.local(2027, 1, 20, 10, 0, 0))

      get serchilo_url(query: "Zamenhof", to: "2026-12-31")

      assert_response :success
      assert_match "Zamenhofa festo en decembro", response.body
      assert_no_match "Zamenhofa festo en januaro", response.body
      assert_select "input[name=to][value='2026-12-31']"
    end
  end

  test "filters events by the from date" do
    travel_to Time.zone.local(2026, 11, 10, 12, 0, 0) do
      create(:event, title: "Zamenhofa festo en novembro", date_start: Time.zone.local(2026, 11, 15, 10, 0, 0))
      create(:event, title: "Zamenhofa festo en decembro", date_start: Time.zone.local(2026, 12, 13, 10, 0, 0))

      get serchilo_url(query: "Zamenhof", from: "2026-12-01")

      assert_response :success
      assert_no_match "Zamenhofa festo en novembro", response.body
      assert_match "Zamenhofa festo en decembro", response.body
    end
  end

  test "keeps events that start before from but run into the period" do
    travel_to Time.zone.local(2026, 11, 10, 12, 0, 0) do
      create(:event,
        title: "Zamenhofa kongreso translanda",
        date_start: Time.zone.local(2026, 12, 10, 10, 0, 0),
        date_end: Time.zone.local(2026, 12, 20, 18, 0, 0))

      get serchilo_url(query: "Zamenhof", from: "2026-12-15", to: "2026-12-31")

      assert_response :success
      assert_match "Zamenhofa kongreso translanda", response.body
    end
  end

  test "ignores invalid dates instead of failing" do
    travel_to Time.zone.local(2026, 11, 10, 12, 0, 0) do
      create(:event, title: "Zamenhofa festo en Vieno", date_start: Time.zone.local(2026, 12, 12, 10, 0, 0))

      get serchilo_url(query: "Zamenhof", from: "ne-dato", to: "2026-13-45")

      assert_response :success
      assert_match "Zamenhofa festo en Vieno", response.body
    end
  end

  test "hides the upcoming and recent note once a period filter is applied" do
    travel_to Time.zone.local(2026, 11, 10, 12, 0, 0) do
      create(:event, title: "Zamenhofa festo en Vieno", date_start: Time.zone.local(2026, 12, 12, 10, 0, 0))

      get serchilo_url(query: "Zamenhof")
      assert_response :success
      assert_match I18n.t("search.results.events.upcoming_and_recent"), response.body

      get serchilo_url(query: "Zamenhof", to: "2026-12-31")
      assert_response :success
      assert_no_match I18n.t("search.results.events.upcoming_and_recent"), response.body
    end
  end

  private

  # Position of the given title in the rendered page.
  #
  # @param title [String] the event title to look for
  # @return [Integer, nil]
  def body_index(title)
    response.body.index(title)
  end
end
