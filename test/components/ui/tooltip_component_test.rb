# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::TooltipComponent.
  class TooltipComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders focusable hint wrapper with Stimulus attributes and aria-label" do
      render_inline(Ui::TooltipComponent.new(text: "Somertempo", placement: :top)) do
        "<i class='fas fa-sun' aria-hidden='true'></i>".html_safe
      end

      assert_selector "span[tabindex='0'][aria-label='Somertempo'][data-controller='hint'][data-hint-text-value='Somertempo'][data-hint-placement-value='top']"
      assert_selector "span.tw\\:focus-visible\\:ring-2 i.fas.fa-sun"
    end

    test "supports bottom, left, and right placements and focusable false" do
      render_inline(Ui::TooltipComponent.new(
        text: "Helpo",
        placement: :bottom,
        focusable: false,
        class: "custom-hint",
        data: {controller: "extra"}
      )) do
        "<button type='button'>Butono</button>".html_safe
      end

      assert_selector "span.custom-hint[data-controller='hint extra'][data-hint-text-value='Helpo'][data-hint-placement-value='bottom']"
      assert_no_selector "span[tabindex]"
      assert_selector "span button", text: "Butono"
    end

    test "raises ArgumentError for unknown placement" do
      assert_raises(ArgumentError) do
        Ui::TooltipComponent.new(text: "Bad", placement: :diagonal)
      end
    end
  end
end
