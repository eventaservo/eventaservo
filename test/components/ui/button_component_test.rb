# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::ButtonComponent.
  class ButtonComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders a standard button element with text parameter" do
      render_inline(Ui::ButtonComponent.new("Konservi"))

      assert_selector "button[type='button']", text: "Konservi"
      assert_selector "button.tw\\:bg-brand-blue.tw\\:text-white"
    end

    test "renders button with block content" do
      render_inline(Ui::ButtonComponent.new) { "Bloka Enhavo" }

      assert_selector "button", text: "Bloka Enhavo"
    end

    test "renders custom button type when specified" do
      render_inline(Ui::ButtonComponent.new("Sendi", type: :submit))

      assert_selector "button[type='submit']", text: "Sendi"
    end

    test "renders an anchor tag when href is provided" do
      render_inline(Ui::ButtonComponent.new("Reeniri", href: "/admin/events"))

      assert_selector "a[href='/admin/events']", text: "Reeniri"
      assert_no_selector "button"
    end

    test "renders success variant with Esperanto green" do
      render_inline(Ui::ButtonComponent.new("Nova", variant: :success))

      assert_selector "button.tw\\:bg-esperanto-500.tw\\:text-white", text: "Nova"
    end

    test "renders outline secondary variant" do
      render_inline(Ui::ButtonComponent.new("Reeniri", variant: :secondary))

      assert_selector "button.tw\\:bg-transparent.tw\\:border-gray-500", text: "Reeniri"
    end

    test "renders cancel variant with dismissive styling" do
      render_inline(Ui::ButtonComponent.new("Nuligi", variant: :cancel))

      assert_selector "button.tw\\:bg-transparent.tw\\:border-transparent.tw\\:text-gray-500", text: "Nuligi"
    end

    test "renders delete variant with brand red styling" do
      render_inline(Ui::ButtonComponent.new("Forigi", variant: :delete))

      assert_selector "button.tw\\:bg-transparent.tw\\:border-transparent.tw\\:text-brand-red", text: "Forigi"
    end

    test "renders different sizes appropriately using small, medium, and large" do
      render_inline(Ui::ButtonComponent.new("Small", size: :small))
      assert_selector "button.tw\\:text-xs.tw\\:px-1\\.5"

      render_inline(Ui::ButtonComponent.new("Medium", size: :medium))
      assert_selector "button.tw\\:text-sm.tw\\:px-2"

      render_inline(Ui::ButtonComponent.new("Large", size: :large))
      assert_selector "button.tw\\:text-base.tw\\:px-3"
    end

    test "supports developer convenience aliases for sizes" do
      render_inline(Ui::ButtonComponent.new("XS", size: :xs))
      assert_selector "button.tw\\:text-xs.tw\\:px-1\\.5"

      render_inline(Ui::ButtonComponent.new("SM", size: :sm))
      assert_selector "button.tw\\:text-sm.tw\\:px-2"

      render_inline(Ui::ButtonComponent.new("MD", size: :md))
      assert_selector "button.tw\\:text-base.tw\\:px-3"
    end

    test "renders leading icon" do
      render_inline(Ui::ButtonComponent.new("Reeniri", icon: "arrow-left"))

      assert_selector "button i.fas.fa-arrow-left[aria-hidden='true']"
    end

    test "renders trailing icon" do
      render_inline(Ui::ButtonComponent.new("Antaŭen", icon: "arrow-right", icon_position: :trailing))

      assert_selector "button i.fas.fa-arrow-right[aria-hidden='true']"
    end

    test "handles disabled state on button elements" do
      render_inline(Ui::ButtonComponent.new("Konservi", disabled: true))

      assert_selector "button[disabled]"
      assert_selector "button.tw\\:opacity-65.tw\\:pointer-events-none"
    end

    test "handles disabled state on link elements accessibly" do
      render_inline(Ui::ButtonComponent.new("Ligilo", href: "/dest", disabled: true))

      assert_selector "a[role='link'][aria-disabled='true'][tabindex='-1']"
      assert_no_selector "a[href]"
      assert_selector "a.tw\\:opacity-65.tw\\:pointer-events-none"
    end

    test "renders full width when enabled" do
      render_inline(Ui::ButtonComponent.new("Plena larĝo", full_width: true))

      assert_selector "button.tw\\:w-full"
    end

    test "merges additional html options and classes" do
      render_inline(
        Ui::ButtonComponent.new(
          "Opcioj",
          id: "custom-btn",
          class: "custom-extra-class",
          data: {action: "click->test#run"}
        )
      )

      assert_selector "button#custom-btn.custom-extra-class[data-action='click->test#run']"
    end
  end
end
