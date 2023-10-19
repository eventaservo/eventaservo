require "test_helper"

class EventRedirectionTest < ActiveSupport::TestCase
  context "Validations" do
    should validate_presence_of(:old_short_url)
    should validate_presence_of(:new_short_url)
  end
end
