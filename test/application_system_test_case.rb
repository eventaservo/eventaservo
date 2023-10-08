# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  using = ENV["CI"].present? ? :headless_chrome : :chrome
  driven_by :selenium, using: using, screen_size: [1440, 900]

  # Load support helpers files
  Dir[Rails.root.join("test", "system", "support", "**", "*.rb")].each do |file|
    require file
    module_name = File.basename(file, ".rb").camelize
    include "System::Support::#{module_name}".constantize
    puts "System::Support::#{module_name}".constantize
  end
end
