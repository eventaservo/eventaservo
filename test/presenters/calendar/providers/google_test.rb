require "test_helper"

class Calendar::Providers::GoogleTest < ActiveSupport::TestCase
  def setup
    @event = build(:event)
    @provider = :google
  end

  test "returns a valid Google Calendar URL" do
    url = Calendar::Providers::Google.new(event: @event, provider: @provider).url
    assert_includes url, "https://www.google.com/calendar/render?action=TEMPLATE"
  end

  # Timezone tests
  class TimezonesTest < ActiveSupport::TestCase
    def setup
      @event = build(:event,
        date_start: Time.zone.parse("2024-01-15 15:00:00 UTC"),
        date_end: Time.zone.parse("2024-01-15 16:00:00 UTC"),
        time_zone: "America/Sao_Paulo")
      @provider = :google
    end

    test "converts timestamps to UTC in the dates parameter" do
      url = Calendar::Providers::Google.new(event: @event, provider: @provider).url
      assert_includes url, "dates=20240115T150000Z%2F20240115T160000Z"
    end

    test "includes the Z suffix to indicate UTC" do
      url = Calendar::Providers::Google.new(event: @event, provider: @provider).url
      assert_match(/dates=\d{8}T\d{6}Z/, url)
    end
  end

  # Event in different timezone tests
  class DifferentTimezoneTest < ActiveSupport::TestCase
    def setup
      @event = build(:event,
        date_start: Time.zone.parse("2024-06-20 14:00:00 UTC"),
        date_end: Time.zone.parse("2024-06-20 15:30:00 UTC"),
        time_zone: "Europe/Madrid")
      @provider = :google
    end

    test "uses UTC timestamps regardless of event timezone" do
      url = Calendar::Providers::Google.new(event: @event, provider: @provider).url
      assert_includes url, "dates=20240620T140000Z%2F20240620T153000Z"
    end
  end

  # Event in UTC timezone tests
  class UTCTimezoneTest < ActiveSupport::TestCase
    def setup
      @event = build(:event,
        date_start: Time.zone.parse("2024-03-10 10:00:00 UTC"),
        date_end: Time.zone.parse("2024-03-10 11:00:00 UTC"),
        time_zone: "Etc/UTC")
      @provider = :google
    end

    test "maintains UTC timestamps correctly" do
      url = Calendar::Providers::Google.new(event: @event, provider: @provider).url
      assert_includes url, "dates=20240310T100000Z%2F20240310T110000Z"
    end
  end
end
