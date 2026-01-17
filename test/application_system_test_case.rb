# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  Capybara.register_driver :remote_chrome do |app|
    chrome_options = Selenium::WebDriver::Chrome::Options.new
    chrome_options.args << "--no-sandbox"
    chrome_options.args << "--disable-gpu"
    chrome_options.args << "--window-size=530,1170"
    chrome_options.args << "--disable-dev-shm-usage"

    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: "http://eventaservo-selenium:4444/wd/hub",
      capabilities: chrome_options
    )
  end

  if ENV["CI"].present?
    driven_by :selenium, using: :headless_chrome, screen_size: [540, 1170]
  elsif ENV["SELENIUM_REMOTE"].present?
    driven_by :remote_chrome
    Capybara.server_host = "0.0.0.0"
    Capybara.server_port = 3001
    Capybara.app_host = "http://backend:3001"
  else
    driven_by :selenium, using: :headless_chrome, screen_size: [540, 1170]
  end

  def login_as(user = nil)
    user ||= create(:user, :e2e_test_user)
    visit new_user_session_path
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "administranto" # Assuming this is the password for the factory user
    click_on "Ensaluti"

    assert_text "Sukcesa ensaluto"
  end
end
