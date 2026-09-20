# frozen_string_literal: true

require "test_helper"

class Users::RegisteredCountsCalculatorTest < ActiveSupport::TestCase
  # Fixture rows are timestamped when the suite loads them, so travelling to a
  # past date keeps every fixture user out of the twelve-month window and the
  # counts only reflect the users created by each test.
  WINDOW = "2026-03-15 12:00:00"

  test "returns one label per month of the last twelve months" do
    travel_to Time.zone.parse(WINDOW) do
      result = Users::RegisteredCountsCalculator.new.call

      assert_equal %w[Apr-25 May-25 Jun-25 Jul-25 Aug-25 Sep-25 Oct-25 Nov-25 Dec-25 Jan-26 Feb-26 Mar-26],
        result[:months]
      assert_equal 12, result[:counts].length
    end
  end

  test "counts registered users cumulatively up to each month end" do
    travel_to Time.zone.parse(WINDOW) do
      create_user(created_at: "2026-02-10 10:00:00")
      create_user(created_at: "2026-03-10 10:00:00")

      result = Users::RegisteredCountsCalculator.new.call

      assert_equal [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2], result[:counts]
    end
  end

  test "counts users registered before the window in every month" do
    travel_to Time.zone.parse(WINDOW) do
      create_user(created_at: "2025-01-01 10:00:00")

      result = Users::RegisteredCountsCalculator.new.call

      assert_equal [1] * 12, result[:counts]
    end
  end

  test "counts a user registered on the last day of a month from the next month on" do
    travel_to Time.zone.parse(WINDOW) do
      create_user(created_at: "2026-02-28 12:00:00")

      result = Users::RegisteredCountsCalculator.new.call

      assert_equal 0, result[:counts][-2]
      assert_equal 1, result[:counts].last
    end
  end

  private

  # Creates a user registered at the given timestamp.
  #
  # @param created_at [String] registration timestamp
  #
  # @return [User] the persisted user
  def create_user(created_at:)
    registered_at = Time.zone.parse(created_at)

    User.create!(
      email: "#{SecureRandom.hex(6)}@example.com",
      password: "password123",
      password_confirmation: "password123",
      name: "Registered User",
      country: countries(:afghanistan),
      username: "registered_#{SecureRandom.hex(6)}",
      confirmed_at: registered_at,
      created_at: registered_at,
      updated_at: registered_at
    )
  end
end
