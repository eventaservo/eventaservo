require "test_helper"

class Calendar::Providers::OutlookTest < ActiveSupport::TestCase
  def setup
    @event = build(:event)
    @provider = :outlook
  end

  test "returns a valid Outlook Calendar URL" do
    url = Calendar::Providers::Outlook.new(event: @event, provider: @provider).url
    assert_includes url, "https://outlook.live.com/calendar/0/deeplink/compose"
  end
end
