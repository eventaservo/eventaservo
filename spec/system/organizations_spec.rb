require "rails_helper"

RSpec.describe "Organizations", type: :system do
  it "should create a new organization" do
    user = create(:user, :e2e_test_user)
    login_as(user)

    visit new_organization_path

    fill_in "organization_name", with: "Test organization"
    fill_in "organization_short_name", with: "test_org"
    find("#organization_display_flag").click # Disable
    find("#organization_display_flag").click # Enable
    fill_in "organization_url", with: "https://www.eventaservo.org"
    fill_in "organization_youtube", with: "https://youtube.com/eventaservo"
    fill_in "organization_email", with: "test@example.com"
    fill_in "organization_phone", with: "+55 83 99999-9999"
    fill_in "organization_url", with: "http://www.eventaservo.org"
    find("#organization_description").click
    send_keys "Test organization description"
    click_on "Registri"

    page.assert_text "Organizo sukcese kreita."
  end
end
