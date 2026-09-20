# frozen_string_literal: true

require "test_helper"

class Organization::SearchTest < ActiveSupport::TestCase
  test "finds organizations by a partial name match" do
    results = Organization.search("Esperantistaj")

    assert_includes results, organizations(:ilei)
    assert_not_includes results, organizations(:sat)
  end

  test "finds organizations by a partial short name match" do
    results = Organization.search("SAT")

    assert_includes results, organizations(:sat)
    assert_not_includes results, organizations(:ilei)
  end

  test "returns every organization when the query is nil" do
    results = Organization.search(nil)

    assert_equal Organization.count, results.count
    assert_includes results, organizations(:ilei)
    assert_includes results, organizations(:sat)
  end

  test "returns every organization when the query is blank" do
    results = Organization.search("   ")

    assert_equal Organization.count, results.count
    assert_includes results, organizations(:ilei)
    assert_includes results, organizations(:sat)
  end

  test "returns an empty relation when no organization matches" do
    results = Organization.search("NeniuOrganizo")

    assert_empty results
  end
end
