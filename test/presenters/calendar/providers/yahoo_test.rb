require "test_helper"

class Calendar::Providers::YahooTest < ActiveSupport::TestCase
  def setup
    @event = build(:event)
    @provider = :yahoo
  end

  test "returns a valid Yahoo Calendar URL" do
    url = Calendar::Providers::Yahoo.new(event: @event, provider: @provider).url
    assert_includes url, "https://calendar.yahoo.com/"
  end
end
