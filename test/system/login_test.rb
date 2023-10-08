require "application_system_test_case"

class LoginTest < ApplicationSystemTestCase
  test "can login successfully" do
    Eventaservo::Application.load_tasks
    Rails.application.load_seed

    visit new_user_session_path
    fill_in "user_email", with: "admin@eventaservo.org"
    fill_in "user_password", with: "administranto"
    click_on "Ensaluti"

    page.assert_text "Sukcesa ensaluto"
    page.assert_text "Administranto"
  end
end
