require "application_system_test_case"

class LoginTest < ApplicationSystemTestCase
  test "can login successfully" do
    Eventaservo::Application.load_tasks
    Rails.application.load_seed

    visit new_user_session_path
    fill_in "user_email", with: "admin@eventaservo.org"
    fill_in "user_password", with: "administranto"
    click_on "Ensaluti"

    page.assert_text "Administranto"

    debugger
    visit destroy_user_session_path

    sleep 5

    page.assert_no_text "Administranto"
  end
  # test "visiting the index" do
  #   visit logins_url
  #
  #   assert_selector "h1", text: "Login"
  # end
end
