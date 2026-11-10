# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::BadgeComponent.
  class BadgeComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders a standard span badge with text parameter" do
      render_inline(Ui::BadgeComponent.new("Kunveno"))

      assert_selector "span.tw\\:rounded-full", text: "Kunveno"
      assert_selector "span.tw\\:bg-brand-info.tw\\:text-white"
    end

    test "renders badge with block content" do
      render_inline(Ui::BadgeComponent.new) { "Bloka Enhavo" }

      assert_selector "span", text: "Bloka Enhavo"
    end

    test "renders anchor tag when href is provided" do
      render_inline(Ui::BadgeComponent.new("Filtrilo", href: "/events?s=1"))

      assert_selector "a[href='/events?s=1']", text: "Filtrilo"
      assert_no_selector "span"
    end

    test "renders rounded shape when specified" do
      render_inline(Ui::BadgeComponent.new("Ronda", shape: :rounded))

      assert_selector "span.tw\\:rounded-\\[3px\\]", text: "Ronda"
    end

    test "renders sizes small, medium, and large" do
      render_inline(Ui::BadgeComponent.new("Eta", size: :small))
      assert_selector "span.tw\\:text-\\[10px\\]"

      render_inline(Ui::BadgeComponent.new("Meza", size: :medium))
      assert_selector "span.tw\\:text-xs"

      render_inline(Ui::BadgeComponent.new("Granda", size: :large))
      assert_selector "span.tw\\:text-sm"
    end

    test "renders standard Bootstrap 1:1 color variants" do
      render_inline(Ui::BadgeComponent.new("Kategorio", variant: :info))
      assert_selector "span.tw\\:bg-brand-info.tw\\:text-white"

      render_inline(Ui::BadgeComponent.new("Karakterizo", variant: :warning))
      assert_selector "span.tw\\:bg-\\[\\#ffc107\\].tw\\:text-gray-950"

      render_inline(Ui::BadgeComponent.new("Internacia", variant: :success))
      assert_selector "span.tw\\:bg-esperanto-500.tw\\:text-white"

      render_inline(Ui::BadgeComponent.new("Proksima", variant: :secondary))
      assert_selector "span.tw\\:bg-gray-600.tw\\:text-white"

      render_inline(Ui::BadgeComponent.new("Urbo", variant: :primary))
      assert_selector "span.tw\\:bg-brand-blue.tw\\:text-white"

      render_inline(Ui::BadgeComponent.new("Malaktiva", variant: :light))
      assert_selector "span.tw\\:bg-gray-100.tw\\:text-gray-800"

      render_inline(Ui::BadgeComponent.new("Nuligita", variant: :danger))
      assert_selector "span.tw\\:bg-brand-red.tw\\:text-white"
    end

    test "renders leading and trailing icons" do
      render_inline(Ui::BadgeComponent.new("Stelo", icon: "star"))
      assert_selector "span i.fas.fa-star[aria-hidden='true']"

      render_inline(Ui::BadgeComponent.new("Sekva", icon: "arrow-right", icon_position: :trailing))
      assert_selector "span i.fas.fa-arrow-right[aria-hidden='true']"
    end

    test "renders removable icon and remove link" do
      render_inline(Ui::BadgeComponent.new("Forigebla", removable: true))
      assert_selector "span i.fa-times"

      render_inline(Ui::BadgeComponent.new("Ligilo", removable: true, remove_href: "/clear"))
      assert_selector "span a[href='/clear'][aria-label='Forigi'] i.fa-times"
    end

    test "merges custom html options and classes" do
      render_inline(
        Ui::BadgeComponent.new(
          "Propra",
          id: "custom-badge",
          class: "custom-class",
          data: {controller: "badge"}
        )
      )

      assert_selector "span#custom-badge.custom-class[data-controller='badge']"
    end
  end
end
