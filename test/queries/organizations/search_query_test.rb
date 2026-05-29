# frozen_string_literal: true

require "test_helper"

module Organizations
  class SearchQueryTest < ActiveSupport::TestCase
    setup do
      @country1 = countries(:country_1)
      @country2 = countries(:country_2)

      @org1 = Organization.create!(
        name: "UEA",
        short_name: "uea",
        country: @country1,
        city: "Rotterdam"
      )
      @org2 = Organization.create!(
        name: "FEJ",
        short_name: "fej",
        country: @country2,
        city: "Paris"
      )
    end

    test "returns all organizations by default ordered by name" do
      query = SearchQuery.new.call
      assert_includes query, @org1
      assert_includes query, @org2
      assert_equal "FEJ", query.first.name
    end

    test "filters by name" do
      params = {name_cont: "UEA"}
      query = SearchQuery.new(params).call
      assert_includes query, @org1
      assert_not_includes query, @org2
    end

    test "filters by country" do
      params = {country_id_eq: @country2.id}
      query = SearchQuery.new(params).call
      assert_not_includes query, @org1
      assert_includes query, @org2
    end

    test "combines multiple filters" do
      params = {name_cont: "FEJ", country_id_eq: @country2.id}
      query = SearchQuery.new(params).call
      assert_equal [@org2], query.to_a
    end

    test "sanitizes name search" do
      params = {name_cont: "U%E_A"}
      query = SearchQuery.new(params).call
      assert_empty query
    end
  end
end
