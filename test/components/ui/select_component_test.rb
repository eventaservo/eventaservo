# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::SelectComponent.
  class SelectComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders basic select dropdown with name and options" do
      options = [["Esperanto", "eo"], ["English", "en"], ["Français", "fr"]]
      render_inline(Ui::SelectComponent.new(:language, options: options, selected: "eo"))

      assert_selector "select[name='language']"
      assert_selector "select option[value='eo'][selected]", text: "Esperanto"
      assert_selector "select option[value='en']", text: "English"
      assert_selector "select option[value='fr']", text: "Français"
    end

    test "renders custom chevron indicator" do
      render_inline(Ui::SelectComponent.new(:category, options: [["Kongreso", "1"]]))

      assert_selector "div.tw\\:pointer-events-none i.fas.fa-chevron-down[aria-hidden='true']"
    end

    test "renders blank option when include_blank is provided" do
      render_inline(Ui::SelectComponent.new(:country, options: [["Brazilo", "br"]], include_blank: "Elektu landon..."))

      assert_selector "select option[value='']", text: "Elektu landon..."
    end

    test "renders prompt option" do
      render_inline(Ui::SelectComponent.new(:type, options: [["Fizika", "physical"]], prompt: "Ĉiuj specoj"))

      assert_selector "select option[value='']", text: "Ĉiuj specoj"
    end

    test "renders label with required indicator when required" do
      render_inline(Ui::SelectComponent.new(:role, label: "Rolo en la evento", required: true))

      assert_selector "label[for='select_role']", text: /Rolo en la evento/
      assert_selector "label span.tw\\:text-red-500", text: "*"
      assert_selector "select[required]"
    end

    test "renders helper hint text linked via aria-describedby" do
      render_inline(Ui::SelectComponent.new(:timezone, label: "Horzono", hint: "La horo de la evento sekvos ĉi tiun zonon."))

      assert_selector "p#select_timezone_hint", text: "La horo de la evento sekvos ĉi tiun zonon."
      assert_selector "select[aria-describedby='select_timezone_hint']"
    end

    test "renders error state with aria-invalid" do
      render_inline(Ui::SelectComponent.new(:organizer, label: "Organizanto", error: "Vi devas elekti organizanton."))

      assert_selector "select[aria-invalid='true']"
      assert_selector "select.tw\\:border-red-500"
      assert_selector "p#select_organizer_error", text: /Vi devas elekti organizanton/
      assert_selector "p i.fas.fa-exclamation-circle[aria-hidden='true']"
    end

    test "renders small and medium sizes" do
      # Small size
      render_inline(Ui::SelectComponent.new(:filter, size: :small))
      assert_selector "select.tw\\:py-1.tw\\:text-xs"

      # Medium size (default)
      render_inline(Ui::SelectComponent.new(:filter, size: :medium))
      assert_selector "select.tw\\:py-1\\.5.tw\\:text-sm"
    end

    test "renders disabled state" do
      render_inline(Ui::SelectComponent.new(:status, disabled: true))

      assert_selector "select[disabled].tw\\:bg-gray-100.tw\\:cursor-not-allowed"
    end

    test "renders options provided via block content" do
      render_inline(Ui::SelectComponent.new(:custom_options)) do
        "<option value='1'>Unua opcio</option><option value='2'>Dua opcio</option>".html_safe
      end

      assert_selector "select[name='custom_options']"
      assert_selector "option[value='1']", text: "Unua opcio"
      assert_selector "option[value='2']", text: "Dua opcio"
    end
  end
end
