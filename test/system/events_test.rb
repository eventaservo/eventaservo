# frozen_string_literal: true

require "application_system_test_case"

class EventsSystemTest < ApplicationSystemTestCase
  test "should create a new event" do
    user = create(:user, :e2e_test_user)
    login_as(user)

    visit new_event_path
    fill_in "event_title", with: "Test event"
    fill_in "event_description", with: "Test event description"
    fill_in "event_date_start", with: Date.today.strftime("%d/%m/%Y")
    fill_in "time_start", with: "12:00"
    fill_in "event_date_end", with: Date.today.strftime("%d/%m/%Y")
    fill_in "time_end", with: "14:00"
    find("#event_enhavo").click
    send_keys "Test event content"
    find("label", text: "Kunveno/Evento").click
    fill_in "event_site", with: "http://www.eventaservo.org"
    fill_in "event_email", with: "admin@eventaservo.org"
    fill_in "event_address", with: "Av. Brasil 123"
    fill_in "event_city", with: "Rio de Janeiro"

    click_on "Registri"

    assert_text "Evento sukcese kreita."
  end
end
