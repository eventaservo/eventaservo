def login_as(user = nil)
  visit new_user_session_path
  fill_in "user_email", with: "admin@eventaservo.org"
  fill_in "user_password", with: "administranto"
  click_on "Ensaluti"

  expect(page).to have_text "Sukcesa ensaluto"
end
