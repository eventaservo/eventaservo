# frozen_string_literal: true

require "test_helper"

class IndexingPolicyTest < ActiveSupport::TestCase
  test "detects filter parameters" do
    assert IndexingPolicy.filtered?({"date" => "2026-01-01"})
    assert IndexingPolicy.filtered?({"s" => "1,2,3"})
    assert IndexingPolicy.filtered?({"o" => "UEA"})
    assert IndexingPolicy.filtered?({"next" => "1"})
    refute IndexingPolicy.filtered?({"page" => "2"})
    refute IndexingPolicy.filtered?({})
  end

  test "staging is never indexed" do
    assert_equal "noindex, nofollow", IndexingPolicy.robots_tag(environment: "staging", filtered: false)
    assert_equal "noindex, nofollow", IndexingPolicy.robots_tag(environment: "staging", filtered: true)
  end

  test "filtered listings are noindex but keep following links" do
    assert_equal "noindex, follow", IndexingPolicy.robots_tag(environment: "production", filtered: true)
  end

  test "plain pages get no directive" do
    assert_nil IndexingPolicy.robots_tag(environment: "production", filtered: false)
  end
end
