# frozen_string_literal: true

require "test_helper"

class TitleNormalizerTest < ActiveSupport::TestCase
  test "removes spaces from title" do
    title = "   hello world  "
    result = TitleNormalizer.new(title).call

    assert_equal "hello world", result
  end

  test "normalizes title with more than 50% uppercase characters" do
    title = "HELLO WORLD"
    result = TitleNormalizer.new(title).call

    assert_equal "Hello World", result
  end

  test "returns original title when less than 50% uppercase characters" do
    title = "hello world"
    result = TitleNormalizer.new(title).call

    assert_equal "hello world", result
  end
end
