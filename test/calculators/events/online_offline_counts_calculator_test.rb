# frozen_string_literal: true

require "test_helper"

class Events::OnlineOfflineCountsCalculatorTest < ActiveSupport::TestCase
  # Fixture rows are timestamped when the suite loads them, so travelling to a
  # past date keeps every fixture event out of the twelve-month window and the
  # counts only reflect the events created by each test.
  WINDOW = "2026-03-15 12:00:00"

  test "returns one x-axis label per month of the last twelve months" do
    travel_to Time.zone.parse(WINDOW) do
      result = Events::OnlineOfflineCountsCalculator.new.call

      assert_equal %w[Apr-25 May-25 Jun-25 Jul-25 Aug-25 Sep-25 Oct-25 Nov-25 Dec-25 Jan-26 Feb-26 Mar-26],
        result[:x_axis]
    end
  end

  test "returns physical and online series in that order" do
    travel_to Time.zone.parse(WINDOW) do
      result = Events::OnlineOfflineCountsCalculator.new.call

      assert_equal %w[Physical Online], result[:events].map { |series| series[:name] }
      assert_equal 12, result[:events].first[:data].length
      assert_equal 12, result[:events].last[:data].length
    end
  end

  test "counts online and physical events created in the current month" do
    travel_to Time.zone.parse(WINDOW) do
      create_event(online: true, created_at: "2026-03-10 10:00:00")
      create_event(online: false, created_at: "2026-03-12 10:00:00")

      result = Events::OnlineOfflineCountsCalculator.new.call
      online_series = result[:events].find { |series| series[:name] == "Online" }[:data]
      physical_series = result[:events].find { |series| series[:name] == "Physical" }[:data]

      assert_equal 1, online_series.last
      assert_equal 1, physical_series.last
    end
  end

  test "counts events per month and leaves unrelated months empty" do
    travel_to Time.zone.parse(WINDOW) do
      # Jan-26 and Feb-26 fall at indices 9 and 10 in an 11..0 window.
      create_event(online: true, created_at: "2026-01-20 10:00:00")
      create_event(online: false, created_at: "2026-01-22 10:00:00")
      create_event(online: true, created_at: "2026-02-20 10:00:00")

      result = Events::OnlineOfflineCountsCalculator.new.call
      online_series = result[:events].find { |series| series[:name] == "Online" }[:data]
      physical_series = result[:events].find { |series| series[:name] == "Physical" }[:data]

      # Jan-26 sits at index 9 (two months before the window's current month)
      # and Feb-26 at index 10; the current month (index 11) has no events.
      assert_equal [0] * 9 + [1, 1, 0], online_series[0, 12]
      assert_equal [0] * 9 + [1, 0, 0], physical_series[0, 12]
    end
  end

  private

  # Creates an event with the given online flag and registration timestamp.
  #
  # @param online [Boolean] whether the event is an online event
  # @param created_at [String] valid creation timestamp
  #
  # @return [Event] the persisted event
  def create_event(online:, created_at:)
    registered_at = Time.zone.parse(created_at)

    create(:event,
      online: online,
      created_at: registered_at,
      updated_at: registered_at,
      date_start: registered_at,
      date_end: registered_at + 2.hours)
  end
end
