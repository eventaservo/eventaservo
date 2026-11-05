# frozen_string_literal: true

require "test_helper"

class EventFilters::CanonicalizerTest < ActiveSupport::TestCase
  test "sorts and deduplicates tag ids" do
    first = tags(:kunveno_evento).id
    second = tags(:kurso).id

    result = EventFilters::Canonicalizer.call({"s" => "#{second},#{first},#{first}"})

    assert_equal "s=#{first}%2C#{second}", result.query
  end

  test "drops tag ids that do not exist" do
    id = tags(:kunveno_evento).id

    assert_equal "s=#{id}", EventFilters::Canonicalizer.call({"s" => "#{id},999999"}).query
  end

  test "drops parameters that are dead or unknown" do
    result = EventFilters::Canonicalizer.call({"f" => "x", "utm_source" => "meta", "o" => ""})

    assert_equal "", result.query
    refute_predicate result, :not_found?
  end

  test "keeps allowed period, duration and past flag" do
    result = EventFilters::Canonicalizer.call({"periodo" => "hodiau", "t" => "unutaga", "pasintaj" => "7"})

    assert_equal "periodo=hodiau&pasintaj=1&t=unutaga", result.query
  end

  test "drops invalid period, duration and false past flag" do
    result = EventFilters::Canonicalizer.call({"periodo" => "sempre", "t" => "kelkaj", "pasintaj" => "0"})

    assert_equal "", result.query
  end

  test "accepts a valid date and rejects invalid ones" do
    assert_equal "date=2026-11-05", EventFilters::Canonicalizer.call({"date" => "2026-11-05"}).query
    assert_equal "", EventFilters::Canonicalizer.call({"date" => "0001-01-01"}).query
    assert_equal "", EventFilters::Canonicalizer.call({"date" => "05/11/2026"}).query
  end

  test "caps pagination and drops the first page" do
    assert_equal "", EventFilters::Canonicalizer.call({"page" => "1"}).query
    assert_equal "page=3", EventFilters::Canonicalizer.call({"page" => "3"}).query
    assert_equal "page=20", EventFilters::Canonicalizer.call({"page" => "999"}).query
    assert_equal "page=3", EventFilters::Canonicalizer.call({"pagho" => "3"}).query
  end

  test "resolves the organization short name ignoring case" do
    result = EventFilters::Canonicalizer.call({"o" => "ROTTERDAM_CENTRE"})

    assert_equal "o=rotterdam_centre", result.query
    refute_predicate result, :not_found?
  end

  test "flags a missing organization" do
    assert_predicate EventFilters::Canonicalizer.call({"o" => "neniu_organizo"}), :not_found?
  end

  test "keeps the supported locale and drops an unknown one" do
    assert_equal "locale=en", EventFilters::Canonicalizer.call({"locale" => "en"}).query
    assert_equal "", EventFilters::Canonicalizer.call({"locale" => "xx"}).query
  end

  test "is idempotent" do
    source = {"s" => "9,1", "periodo" => "p7_tagojn", "f" => "x", "page" => "42"}
    first = EventFilters::Canonicalizer.call(source)
    parsed = Rack::Utils.parse_nested_query(first.query)

    assert_equal first.query, EventFilters::Canonicalizer.call(parsed).query
  end
end
