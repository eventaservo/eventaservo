# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::NavbarComponent.
  class NavbarComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders base navigation bar element" do
      render_inline(Ui::NavbarComponent.new)

      assert_selector "nav.tw\\:bg-esperanto-500.tw\\:text-white"
      assert_selector "button.tw\\:bg-transparent.tw\\:border-white\\/20[aria-label='Navigado'] i.fa-bars"
    end

    test "renders brand slot with title and destination link" do
      render_inline(Ui::NavbarComponent.new) do |nav|
        nav.with_brand(title: "Eventa Servo", href: "/cxefa")
      end

      assert_selector "a[href='/cxefa']", text: "Eventa Servo"
      assert_selector "a.tw\\:font-bold.tw\\:text-lg"
    end

    test "renders brand environment tag when specified" do
      render_inline(Ui::NavbarComponent.new) do |nav|
        nav.with_brand(title: "Eventa Servo", env_badge: "STAGING")
      end

      assert_selector "span.tw\\:bg-black\\/25", text: "STAGING"
    end

    test "renders search slot with controller attributes" do
      render_inline(Ui::NavbarComponent.new) do |nav|
        nav.with_search(placeholder: "Serĉi eventojn...", url: "/sercho")
      end

      assert_selector "form[data-controller='search'][data-search-url-value='/sercho']"
      assert_selector "input[type='search'][placeholder='Serĉi eventojn...']"
      assert_selector "i.fa-search"
    end

    test "renders navigation items with icons and active states" do
      render_inline(Ui::NavbarComponent.new) do |nav|
        nav.with_item("Eventoj", href: "/events", icon: "calendar", active: true)
        nav.with_item("Kluboj", href: "/clubs", icon: "users", active: false)
      end

      assert_selector "a[href='/events'][aria-current='page']", text: "Eventoj"
      assert_selector "a.tw\\:bg-esperanto-700", text: "Eventoj"
      assert_selector "a[href='/clubs']", text: "Kluboj"
      assert_no_selector "a[href='/clubs'][aria-current='page']"
      assert_selector "i.fa-calendar"
      assert_selector "i.fa-users"
    end

    test "renders action slot with primary call to action" do
      render_inline(Ui::NavbarComponent.new) do |nav|
        nav.with_action do
          tag.a("+ Aldoni eventon", href: "/events/new", class: "tw:font-semibold")
        end
      end

      assert_selector "a[href='/events/new']", text: "+ Aldoni eventon"
    end

    test "renders tool buttons with highlights and aria labels" do
      render_inline(Ui::NavbarComponent.new) do |nav|
        nav.with_tool(icon: "map-marker-alt", href: "/mapo", label: "Mapo", active: true)
        nav.with_tool(icon: "heart", href: "https://support.org", label: "Subteni", target: "_blank")
      end

      assert_selector "a[href='/mapo'][aria-label='Mapo'].tw\\:bg-yellow-400"
      assert_selector "a[href='https://support.org'][target='_blank'][rel='noopener noreferrer']"
      assert_selector "i.fa-map-marker-alt"
      assert_selector "i.fa-heart"
    end

    test "renders user menu slot" do
      render_inline(Ui::NavbarComponent.new) do |nav|
        nav.with_user_menu do
          tag.span("Uzanto: Zamenhof", class: "tw:text-xs")
        end
      end

      assert_selector "span.tw\\:text-xs", text: "Uzanto: Zamenhof"
    end
  end
end
