require "application_system_test_case"

class EventTEst < ApplicationSystemTestCase
  def setup
    existing_admin_user = User.find_by(email: "admin@eventaservo.org")

    @admin =
      if existing_admin_user.nil?
        FactoryBot.create(:user, email: "admin@eventaservo.org", password: "administranto")
      else
        existing_admin_user
      end
  end

  test "create a new event" do
    login_as(@user)

    visit new_event_path
    fill_in "event_title", with: "Test event"
    fill_in "event_description", with: "Test event description"
    fill_in "event_date_start", with: Date.today.strftime("%d/%m/%Y")
    fill_in "time_start", with: "12:00"
    fill_in "event_date_end", with: Date.today.strftime("%d/%m/%Y")
    fill_in "time_end", with: "14:00"
    find("#specolisto_Loka").first(:xpath, ".//..").click
    find("#event_enhavo").click
    send_keys "Test event content"
    fill_in "event_site", with: "http://www.eventaservo.org"
    fill_in "event_email", with: "admin@eventaservo.org"
    fill_in "event_address", with: "Av. Brasil 123"
    fill_in "event_city", with: "Rio de Janeiro"
    find("#select2-event_country_id-container").click
    find(".select2-search__field").click
    send_keys "Brazilo", :enter

    click_on "Registri"

    page.assert_text "Evento sukcese kreita."
  end
end
