# frozen_string_literal: true

require "test_helper"

module Logs
  class SearchQueryTest < ActiveSupport::TestCase
    setup do
      @user = users(:user)
      @admin = users(:admin_user)

      @log1 = Log.create!(
        user: @user,
        text: "User action",
        created_at: Time.zone.parse("2026-03-10 10:00:00")
      )

      @log2 = Log.create!(
        user: @admin,
        text: "Admin update",
        created_at: Time.zone.parse("2026-03-12 15:00:00")
      )
    end

    test "returns all logs by default ordered by created_at desc" do
      query = SearchQuery.new.call
      assert_equal [@log2, @log1], query.to_a
    end

    test "filters by user_name" do
      params = {user_name: @user.name}
      query = SearchQuery.new(params).call
      assert_includes query, @log1
      assert_not_includes query, @log2
    end

    test "filters by text" do
      params = {text: "Admin"}
      query = SearchQuery.new(params).call
      assert_not_includes query, @log1
      assert_includes query, @log2
    end

    test "filters by start_date" do
      params = {start_date: "2026-03-11"}
      query = SearchQuery.new(params).call
      assert_not_includes query, @log1
      assert_includes query, @log2
    end

    test "filters by end_date" do
      params = {end_date: "2026-03-11"}
      query = SearchQuery.new(params).call
      assert_includes query, @log1
      assert_not_includes query, @log2
    end

    test "handles invalid start_date gracefully (ArgumentError)" do
      params = {start_date: "invalid-date"}
      query = SearchQuery.new(params).call
      assert_equal 2, query.count
    end

    test "handles invalid end_date gracefully (ArgumentError)" do
      params = {end_date: "invalid-date"}
      query = SearchQuery.new(params).call
      assert_equal 2, query.count
    end

    test "handles TypeError in dates gracefully" do
      # Passing something that might cause TypeError in parse or beginning_of_day
      params = {start_date: ["not", "a", "string"], end_date: {also: "not"}}
      query = SearchQuery.new(params).call
      assert_equal 2, query.count
    end

    test "handles dates that parse to nil" do
      params = {start_date: " ", end_date: ""}
      query = SearchQuery.new(params).call
      assert_equal 2, query.count
    end

    test "combines multiple filters" do
      params = {user_name: @admin.name, text: "Admin"}
      query = SearchQuery.new(params).call
      assert_equal [@log2], query.to_a
    end
  end
end
