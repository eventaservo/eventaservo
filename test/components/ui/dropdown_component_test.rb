# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::DropdownComponent.
  class DropdownComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders trigger and hidden menu panel with ARIA and Stimulus attributes" do
      render_inline(Ui::DropdownComponent.new(menu_id: "test-menu")) do |menu|
        menu.with_trigger("Elektoj", icon: "bars")
        menu.with_item("Vidi", href: "/events")
      end

      assert_selector "div[data-controller='menu']"
      assert_selector "button[data-menu-target='button'][data-action='click->menu#toggle'][aria-haspopup='true'][aria-expanded='false'][aria-controls='test-menu']", text: "Elektoj"
      assert_selector "div#test-menu.tw\\:hidden[role='menu'][data-menu-target='panel'][data-menu-hidden-class='tw:hidden']"
      assert_selector "a[role='menuitem'][tabindex='-1'][data-menu-target='item'][href='/events']", text: "Vidi"
    end

    test "renders custom trigger block content" do
      render_inline(Ui::DropdownComponent.new(menu_id: "custom-trigger-menu")) do |menu|
        menu.with_trigger(caret: false) { "Propra Butono" }
        menu.with_item("Ago", href: "/ago")
      end

      assert_selector "button[data-menu-target='button']", text: "Propra Butono"
    end

    test "renders items with icons, active state, and destructive styling" do
      render_inline(Ui::DropdownComponent.new) do |menu|
        menu.with_trigger("Menuo")
        menu.with_item("Aktiva", href: "/aktiva", icon: "check", active: true)
        menu.with_item("Forigi", href: "/forigi", icon: "trash", destructive: true)
      end

      assert_selector "a.tw\\:bg-esperanto-50.tw\\:text-esperanto-700", text: "Aktiva"
      assert_selector "a i.fas.fa-check"
      assert_selector "a.tw\\:text-red-700", text: "Forigi"
      assert_selector "a i.fas.fa-trash"
    end

    test "renders section headers and dividers in order" do
      render_inline(Ui::DropdownComponent.new) do |menu|
        menu.with_trigger("Konto")
        menu.with_header("Profilo")
        menu.with_item("Mia profilo", href: "/profilo")
        menu.with_divider
        menu.with_item("Elsaluti", href: "/elsaluti")
      end

      assert_selector "div[role='presentation']", text: "Profilo"
      assert_selector "div[role='separator'].tw\\:border-t"
    end

    test "supports left/right alignment and down/up expansion direction" do
      render_inline(Ui::DropdownComponent.new(align: :left, direction: :down)) do |menu|
        menu.with_trigger("Malsupren")
      end
      assert_selector "div[role='menu'].tw\\:left-0.tw\\:top-full"

      render_inline(Ui::DropdownComponent.new(align: :right, direction: :up)) do |menu|
        menu.with_trigger("Supren")
      end
      assert_selector "div[role='menu'].tw\\:right-0.tw\\:bottom-full"
    end

    test "supports trigger variants with Tailwind v4 variant prefix classes" do
      render_inline(Ui::DropdownComponent.new) do |menu|
        menu.with_trigger("Defaŭlta", variant: :default)
      end
      assert_selector "button.tw\\:bg-white.tw\\:hover\\:bg-gray-50.tw\\:focus\\:outline-none"

      render_inline(Ui::DropdownComponent.new) do |menu|
        menu.with_trigger("Fantomo", variant: :ghost)
      end
      assert_selector "button.tw\\:bg-transparent.tw\\:hover\\:bg-gray-100"

      render_inline(Ui::DropdownComponent.new) do |menu|
        menu.with_trigger("Hela", variant: :light)
      end
      assert_selector "button.tw\\:bg-gray-100.tw\\:hover\\:bg-gray-200"

      render_inline(Ui::DropdownComponent.new) do |menu|
        menu.with_trigger("Ĉefa", variant: :primary)
      end
      assert_selector "button.tw\\:bg-esperanto-500.tw\\:hover\\:bg-esperanto-600"

      render_inline(Ui::DropdownComponent.new) do |menu|
        menu.with_trigger("Inversa", variant: :inverse)
      end
      assert_selector "button.tw\\:text-white\\/95.tw\\:hover\\:bg-white\\/15"
    end

    test "supports panel width options and custom item/header blocks" do
      render_inline(Ui::DropdownComponent.new(width: :auto)) do |menu|
        menu.with_trigger("Aŭtomata")
        menu.with_header { "Propra Kapo" }
        menu.with_item(href: "/propra") { "Propraero" }
      end
      assert_selector "div[role='menu'].tw\\:min-w-48"
      assert_selector "div[role='presentation']", text: "Propra Kapo"
      assert_selector "a[role='menuitem'].tw\\:hover\\:bg-gray-100.tw\\:focus\\:bg-gray-100", text: "Propraero"

      render_inline(Ui::DropdownComponent.new(width: :medium)) do |menu|
        menu.with_trigger("Meza")
      end
      assert_selector "div[role='menu'].tw\\:w-56"

      render_inline(Ui::DropdownComponent.new(width: :large)) do |menu|
        menu.with_trigger("Larĝa")
      end
      assert_selector "div[role='menu'].tw\\:w-64"
    end
  end
end
