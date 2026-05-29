# frozen_string_literal: true

require "test_helper"

class EventsController::InternationalBadgeTest < ActionDispatch::IntegrationTest
  test "renders international badge on show page when event is international" do
    event = create(:event, :international_calendar)

    get event_path(code: event.code)
    assert_response :success
    assert_select ".text-bg-success", text: /Internacia Evento/
  end

  test "does not render international badge on show page when event is local" do
    event = create(:event, international_calendar: false)

    get event_path(code: event.code)
    assert_response :success
    assert_select ".text-bg-success", false
  end
end
