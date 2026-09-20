# frozen_string_literal: true

require "test_helper"

class Video::SearchTest < ActiveSupport::TestCase
  test "finds videos by a partial title match" do
    results = Video.search("Introduction")

    assert_includes results, videos(:rails_conference_video)
    assert_not_includes results, videos(:esperanto_meetup_video)
  end

  test "finds videos by a partial description match" do
    results = Video.search("monata")

    assert_includes results, videos(:esperanto_meetup_video)
    assert_not_includes results, videos(:rails_conference_video)
  end

  test "ignores accents when matching" do
    results = Video.search("renkontigo")

    assert_includes results, videos(:esperanto_meetup_video)
    assert_not_includes results, videos(:rails_conference_video)
  end

  test "orders the results by the most recent event first" do
    results = Video.search("a")

    assert_equal [videos(:rails_conference_video), videos(:esperanto_meetup_video)], results.to_a
  end

  test "returns every video when the query is nil" do
    results = Video.search(nil)

    assert_equal Video.count, results.count
  end

  test "returns every video when the query is blank" do
    results = Video.search("   ")

    assert_equal Video.count, results.count
  end

  test "returns an empty relation when no video matches" do
    results = Video.search("NeniuVideo")

    assert_empty results
  end
end
