# frozen_string_literal: true

require "application_system_test_case"

class InterestedButtonTest < ApplicationSystemTestCase
  test "user can mark interest in an event" do
    user = create(:user, :e2e_test_user)
    event = create(:event)

    login_as(user)
    visit event_path(code: event.ligilo)

    # Initial state: "Mi interesiĝas" button is visible
    assert_selector "[data-event-user-interested-button-target='button']", text: "Mi interesiĝas"
    assert_selector "[data-event-user-interested-button-target='question']", visible: false

    # Click the button
    find("[data-event-user-interested-button-target='button']").click

    # Interaction: Question appears
    assert_selector "[data-event-user-interested-button-target='question']", visible: true
    assert_text "Ĉu aperigi vian nomon en la listo de interesiĝantoj?"

    # Click "JES" to confirm interest
    click_link "JES"

    # Verify update: Button changes to "Mi interesiĝas!" (user-check icon)
    assert_text "Mi interesiĝas!"
    assert_selector ".fa-user-check"
  end
end
