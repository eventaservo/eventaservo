# frozen_string_literal: true

require "test_helper"

class User::SearchTest < ActiveSupport::TestCase
  test "finds users by a partial name match" do
    results = User.search("Bruno")

    assert_includes results, users(:speaker)
    assert_not_includes results, users(:teacher)
  end

  test "finds users by a partial username match" do
    results = User.search("standard_user")

    assert_includes results, users(:user)
    assert_not_includes results, users(:speaker)
  end

  test "treats spaces as wildcards between words" do
    results = User.search("Carla Ambaŭ")

    assert_includes results, users(:teacher_and_speaker)
    assert_not_includes results, users(:teacher)
  end

  test "finds users through the organizations they belong to" do
    OrganizationUser.create!(organization: organizations(:sat), user: users(:teacher))

    results = User.search("SAT")

    assert_includes results, users(:teacher)
    assert_not_includes results, users(:speaker)
  end

  test "returns every user when the query is nil" do
    results = User.search(nil)

    assert_equal User.count, results.count
  end

  test "returns every user when the query is blank" do
    results = User.search("   ")

    assert_equal User.count, results.count
  end

  test "returns an empty relation when no user matches" do
    results = User.search("NeniuUzanto")

    assert_empty results
  end
end
