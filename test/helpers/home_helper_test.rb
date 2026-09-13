# frozen_string_literal: true

require "test_helper"

class HomeHelperTest < ActionView::TestCase
  test "returns the label for known periods" do
    assert_equal "Okazas nuntempe", period_label("hodiau")
    assert_equal "Proksimajn 7 tagojn", period_label("p7_tagojn")
    assert_equal "Proksimajn 30 tagojn", period_label("p30_tagojn")
    assert_equal "Estontece", period_label("estontece")
  end

  test "returns the given period when it has no known label" do
    assert_equal "Unknown", period_label("Unknown")
  end

  test "returns nil when the period is nil" do
    assert_nil period_label(nil)
  end
end
