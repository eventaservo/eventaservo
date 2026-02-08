require "test_helper"

class EventTagojTest < ActiveSupport::TestCase
  def setup
    @original_time_zone = Time.zone
  end

  def teardown
    Time.zone = @original_time_zone
  end

  test "tagoj calculates duration statistics correctly for ongoing event" do
    # Freeze time to 2023-06-15 12:00:00 UTC
    travel_to Time.utc(2023, 6, 15, 12, 0, 0) do
      # Event runs from June 13 to June 17 (5 days) in Paris
      # Paris is UTC+2 in June (CEST)
      # 2023-06-13 10:00 Paris -> 08:00 UTC
      # 2023-06-17 18:00 Paris -> 16:00 UTC
      event = Event.new(
        title: "Test Event",
        time_zone: "Europe/Paris",
        date_start: Time.utc(2023, 6, 13, 8, 0, 0),
        date_end: Time.utc(2023, 6, 17, 16, 0, 0),
        city: "Paris",
        country: countries(:country_58) # Francio
      )

      stats = event.tagoj

      # Explanation of calculation:
      # komenca_tago (Paris): 13/06/2023
      # fina_tago (Paris): 17/06/2023
      # Total days: (17 - 13) + 1 = 5
      #
      # Today (Paris): 15/06/2023 (12:00 UTC is 14:00 CEST)
      # Parcial: (15 - 13) + 1 = 3
      # Restanta: 5 - 3 = 2
      # Percent: (3.0 / 5.0) * 100 = 60

      assert_equal 5, stats[:total], "Total days should be 5"
      assert_equal 3, stats[:parcial], "Passed days should be 3"
      assert_equal 2, stats[:restanta], "Remaining days should be 2"
      assert_equal 60, stats[:percent], "Percentage should be 60%"
    end
  end
end
