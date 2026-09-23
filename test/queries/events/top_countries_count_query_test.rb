# frozen_string_literal: true

require "test_helper"

class Events::TopCountriesCountQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
  end

  test "returns countries and counts as parallel series, most events first" do
    3.times { create_event(country_id: countries(:albania).id) }

    result = Events::TopCountriesCountQuery.new.call

    # Three events in Albanio beat the two fixture events of Afganio and Danio.
    assert_equal ["Albanio", "Afganio", "Danio"], result[:countries]
    assert_equal [3, 2, 2], result[:counts]
  end

  test "breaks count ties alphabetically by country name" do
    2.times { create_event(country_id: countries(:albania).id) } # ties Albanio with Afganio and Danio at two

    result = Events::TopCountriesCountQuery.new.call

    # Afganio, Albanio and Danio are all tied at two events: alphabetical order wins.
    assert_equal ["Afganio", "Albanio", "Danio"], result[:countries]
    assert_equal [2, 2, 2], result[:counts]
  end

  test "limits the result to fifteen countries" do
    (2..18).each { |country_id| create_event(country_id: country_id) }

    result = Events::TopCountriesCountQuery.new.call

    assert_equal 15, result[:countries].length
    assert_equal 15, result[:counts].length
  end

  private

  # Creates an event assigned to the given country.
  #
  # @param country_id [Integer] the country the event belongs to
  #
  # @return [Event] the persisted event
  def create_event(country_id:)
    Event.create!(
      title: "Top country test",
      description: "Test event",
      city: "Test City",
      country_id: country_id,
      date_start: 1.week.from_now,
      date_end: 1.week.from_now + 2.hours,
      time_zone: "Etc/UTC",
      code: SecureRandom.hex(6),
      site: "https://test.example.com",
      user: @user
    )
  end
end
