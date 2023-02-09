# frozen_string_literal: true

require "test_helper"

class CoreExtensionsTest < ActiveSupport::TestCase
  test "normalize text" do
    assert_equal "europo", "Eŭropo".normalized
    assert_equal "europo", "Euxropo".normalized
  end
end
