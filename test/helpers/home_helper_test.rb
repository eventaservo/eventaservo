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

  test "reports active filters when a supported filter param is present" do
    @controller.params = ActionController::Parameters.new(periodo: "estontece")

    assert active_filters?
  end

  test "reports active filters for each supported filter param" do
    ["o", "periodo", "s"].each do |param|
      @controller.params = ActionController::Parameters.new(param => "some value")

      assert active_filters?, "expected the #{param} param to be reported as an active filter"
    end
  end

  test "reports no active filters when there is no supported filter param" do
    @controller.params = ActionController::Parameters.new

    assert_not active_filters?

    @controller.params = ActionController::Parameters.new(pasintaj: "true")

    assert_not active_filters?
  end

  test "returns only the supported filters, permitted for reuse" do
    @controller.params = ActionController::Parameters.new(o: "esperanto", periodo: "estontece", pasintaj: "true")

    result = active_filters

    assert_equal({"o" => "esperanto", "periodo" => "estontece"}, result.to_h)
    assert result.permitted?
  end

  test "returns an empty permitted param set when no filter is active" do
    @controller.params = ActionController::Parameters.new

    result = active_filters

    assert_equal({}, result.to_h)
    assert result.permitted?
  end

  test "drops a filter param so the remaining ones can be kept in the URL" do
    @controller.params = ActionController::Parameters.new(o: "esperanto", periodo: "estontece")

    result = active_filters.except(:o)

    assert_equal({"periodo" => "estontece"}, result.to_h)
  end
end
