require "test_helper"

class Calendar::Providers::AppleTest < ActiveSupport::TestCase
  def setup
    @event = build(:event)
    @provider = :apple
  end

  test "returns a valid Apple Calendar URL" do
    url = Calendar::Providers::Apple.new(event: @event, provider: @provider).url
    assert_includes url, "/e/#{@event.code}.ics"
  end
end
