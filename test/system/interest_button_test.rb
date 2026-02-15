# frozen_string_literal: true

require "application_system_test_case"

class InterestButtonSystemTest < ApplicationSystemTestCase
  test "user can see and click the interest button" do
    user = create(:user, password: "administranto")
    event = create(:event)

    # Manually login because login_as assumes :e2e_test_user specific email/password combo in some cases or just uses user passed
    visit new_user_session_path
    fill_in "Retpoŝtadreso", with: user.email
    fill_in "Pasvorto", with: "administranto"
    click_on "Ensaluti"
    assert_text "Sukcesa ensaluto"

    visit event_path(code: event.code)

    # Check for the button text - using find to be specific about the text
    assert_text "Mi interesiĝas"

    # Click the element (now a button)
    find("button.link-blue", text: "Mi interesiĝas").click

    # Check for the YES/NO buttons
    assert_text "Ĉu aperigi vian nomon en la listo de interesiĝantoj?"
    assert_selector "a", text: "JES"
    assert_selector "a", text: "NE"
  end
end
