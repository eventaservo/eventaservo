# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::CheckboxComponent.
  class CheckboxComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders basic checkbox with name and default value" do
      render_inline(Ui::CheckboxComponent.new(:agree, label: "Mi konsentas"))

      assert_selector "input[type='checkbox'][name='agree'][value='1']"
      assert_selector "label", text: "Mi konsentas"
      assert_selector "input.tw\\:custom-checkbox"
    end

    test "renders checked state when checked is true" do
      render_inline(Ui::CheckboxComponent.new(:terms, checked: true, label: "Kondiĉoj"))

      assert_selector "input[type='checkbox'][checked]"
    end

    test "renders block content as label" do
      render_inline(Ui::CheckboxComponent.new(:subscribe)) do
        "Ricevi la monatan bultenon"
      end

      assert_selector "label span", text: "Ricevi la monatan bultenon"
    end

    test "renders helper hint text linked via aria-describedby" do
      render_inline(Ui::CheckboxComponent.new(:updates, label: "Sciigoj", hint: "Vi povos malaboni iam ajn."))

      assert_selector "p#checkbox_updates_hint", text: "Vi povos malaboni iam ajn."
      assert_selector "input[aria-describedby='checkbox_updates_hint']"
    end

    test "renders validation error state with aria-invalid" do
      render_inline(Ui::CheckboxComponent.new(:terms, label: "Reguloj", error: "Vi devas akcepti la regulojn."))

      assert_selector "input[aria-invalid='true']"
      assert_selector "input.tw\\:border-red-500"
      assert_selector "p#checkbox_terms_error", text: /Vi devas akcepti la regulojn/
      assert_selector "p i.fas.fa-exclamation-circle[aria-hidden='true']"
    end

    test "renders small and medium sizes" do
      # Small size
      render_inline(Ui::CheckboxComponent.new(:filter, label: "Filtrilo", size: :small))
      assert_selector "input.tw\\:w-3\\.5.tw\\:h-3\\.5.tw\\:rounded-\\[3px\\]"
      assert_selector "span.tw\\:text-xs"

      # Medium size (default)
      render_inline(Ui::CheckboxComponent.new(:filter, label: "Filtrilo", size: :medium))
      assert_selector "input.tw\\:w-4.tw\\:h-4.tw\\:rounded-\\[4px\\]"
      assert_selector "span.tw\\:text-sm"
    end

    test "renders disabled state" do
      render_inline(Ui::CheckboxComponent.new(:locked, label: "Ŝlosita", disabled: true))

      assert_selector "label.tw\\:cursor-not-allowed.tw\\:opacity-60"
      assert_selector "input[disabled]"
    end

    test "renders items-center when no hint and items-start when hint is present" do
      render_inline(Ui::CheckboxComponent.new(:no_hint, label: "Sen helpteksto"))
      assert_selector "label.tw\\:items-center"

      render_inline(Ui::CheckboxComponent.new(:with_hint, label: "Kun helpteksto", hint: "Klariga noto"))
      assert_selector "label.tw\\:items-start"
    end

    test "forwards arbitrary HTML attributes" do
      render_inline(Ui::CheckboxComponent.new(:custom, label: "Propra", data: {test_id: "cb-1"}))

      assert_selector "input[data-test-id='cb-1']"
    end
  end
end
