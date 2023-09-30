# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  using = ENV["CI"].present? ? :headless_chrome : :chrome
  driven_by :selenium, using: using, screen_size: [1440, 900]
end
