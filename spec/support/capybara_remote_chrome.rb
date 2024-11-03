Capybara.register_driver :remote_chrome do |app|
  chrome_options = Selenium::WebDriver::Chrome::Options.new
  chrome_options.args << "--no-sandbox"
  chrome_options.args << "--headless"
  chrome_options.args << "--disable-gpu"
  chrome_options.args << "--window-size=530,1170"
  chrome_options.args << "--disable-dev-shm-usage" # Prevent crashes

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: "http://selenium:4444/wd/hub",
    capabilities: chrome_options
  )
end
