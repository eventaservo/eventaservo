require "test_helper"
require "minitest/mock"

class HorzonoTest < ActiveSupport::TestCase
  test "for_select returns an array of [eo, en] pairs" do
    result = Horzono.for_select

    assert_kind_of Array, result
    assert result.any?
    assert result.all? { |pair| pair.is_a?(Array) && pair.size == 2 }

    first_timezone = Horzono.first
    assert_includes result, [first_timezone.eo, first_timezone.en]
  end

  test "for_select caches the result" do
    memory_store = ActiveSupport::Cache.lookup_store(:memory_store)

    Rails.stub :cache, memory_store do
      Rails.cache.clear
      assert_changes -> { Rails.cache.exist?("horzono/for_select") }, from: false, to: true do
        Horzono.for_select
      end
    end

    # We test that Rails.cache.fetch is called with correct parameters
    mock_cache = Minitest::Mock.new
    mock_cache.expect(:fetch, [["Esperanto", "English"]], ["horzono/for_select"], expires_in: 1.day)

    Rails.stub(:cache, mock_cache) do
      assert_equal [["Esperanto", "English"]], Horzono.for_select
    end

    assert_mock mock_cache
  end
end
