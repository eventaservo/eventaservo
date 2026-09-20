# frozen_string_literal: true

require "test_helper"

# Tests the chart data with cumulative registered event counts per month.
class HomeController::RegisteredEventsCountsTest < ActionDispatch::IntegrationTest
  test "returns cumulative event counts up to the end of each of the last twelve months" do
    travel_to Time.zone.parse("2020-06-15 12:00:00") do
      create_event(created_at: "2019-06-15") # before the twelve-month window
      create_event(created_at: "2019-07-05") # oldest month in the window
      2.times { create_event(created_at: "2019-08-10") }
      3.times { create_event(created_at: "2020-02-10") } # leap-year February
      create_event(created_at: "2020-06-10") # current month

      result = HomeController.new.send(:registered_events_counts)

      assert_equal %w[Jul-19 Aug-19 Sep-19 Oct-19 Nov-19 Dec-19
        Jan-20 Feb-20 Mar-20 Apr-20 May-20 Jun-20], result[:monatoj]
      assert_equal [2, 4, 4, 4, 4, 4, 4, 7, 7, 7, 7, 8], result[:kvantoj]
    end
  end

  private

  # Creates an event with an explicit creation timestamp.
  #
  # @param created_at [String] creation timestamp used as the count boundary probe
  #
  # @return [Event] the created event
  def create_event(created_at:)
    event_created_at = Time.zone.parse(created_at)

    Event.create!(
      title: "Boundary event",
      description: "Test event",
      city: "Test City",
      country_id: 1,
      date_start: event_created_at,
      date_end: event_created_at + 2.hours,
      time_zone: "Etc/UTC",
      code: SecureRandom.hex(6),
      site: "https://test.example.com",
      user: users(:user),
      created_at: event_created_at
    )
  end
end
