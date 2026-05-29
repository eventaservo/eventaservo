require "test_helper"

class Calendar::Providers::IcsFileTest < ActiveSupport::TestCase
  def setup
    @event = build(:event)
    @provider = :ics_file
  end

  test "returns a valid ICS file to download" do
    url = Calendar::Providers::IcsFile.new(event: @event, provider: @provider).url
    assert_includes url, "/e/#{@event.code}.ics"
  end
end
