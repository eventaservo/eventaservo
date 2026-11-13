# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::TabsComponent.
  class TabsComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders tablist, tabs, and panels with WAI-ARIA and Stimulus attributes" do
      render_inline(Ui::TabsComponent.new(id: "event-tabs", aria_label: "Sekcioj")) do |tabs|
        tabs.with_tab(id: "info", label: "Informoj") { "Unua panelo" }
        tabs.with_tab(id: "program", label: "Programo") { "Dua panelo" }
      end

      assert_selector "div#event-tabs[data-controller='tabs'][data-tabs-index-value='0']"
      assert_selector "div[role='tablist'][aria-label='Sekcioj']"

      assert_selector "button#info-tab[role='tab'][aria-controls='info-panel'][aria-selected='true'][tabindex='0'][data-tabs-target='tab'][data-action='click->tabs#select']", text: "Informoj"
      assert_selector "button#program-tab[role='tab'][aria-controls='program-panel'][aria-selected='false'][tabindex='-1'][data-tabs-target='tab'][data-action='click->tabs#select']", text: "Programo"

      assert_selector "div#info-panel.show.active[role='tabpanel'][aria-labelledby='info-tab'][tabindex='0'][data-tabs-target='panel'][data-tabs-hidden-class='tw:hidden']", text: "Unua panelo"
      assert_selector "div#program-panel.tw\\:hidden[role='tabpanel'][aria-labelledby='program-tab'][tabindex='0'][data-tabs-target='panel']", text: "Dua panelo"
    end

    test "respects explicit active tab selection" do
      render_inline(Ui::TabsComponent.new(id: "custom-tabs")) do |tabs|
        tabs.with_tab(id: "first", label: "Unua") { "Enhavo 1" }
        tabs.with_tab(id: "second", label: "Dua", active: true) { "Enhavo 2" }
      end

      assert_selector "div#custom-tabs[data-tabs-index-value='1']"
      assert_selector "button#first-tab[aria-selected='false'][tabindex='-1']"
      assert_selector "button#second-tab.active[aria-selected='true'][tabindex='0']"
      assert_selector "div#first-panel.tw\\:hidden"
      assert_selector "div#second-panel.show.active"
    end

    test "renders optional icons, count pills, and Tailwind v4 variant prefix classes" do
      render_inline(Ui::TabsComponent.new) do |tabs|
        tabs.with_tab(id: "reports", label: "Raportoj", icon: "camera", count: 7, active: true) { "Raportoj enhavo" }
        tabs.with_tab(id: "past", label: "Pasintaj", count: 0) { "Pasintaj enhavo" }
      end

      assert_selector "button#reports-tab i.fas.fa-camera"
      assert_selector "button#reports-tab span.tw\\:bg-esperanto-100.tw\\:text-esperanto-600", text: "7"
      assert_selector "button#past-tab span.tw\\:bg-gray-100.tw\\:text-gray-600", text: "0"
      assert_selector "button#reports-tab.tw\\:border-0.tw\\:border-b-2.tw\\:border-solid.tw\\:focus-visible\\:outline-none"
      assert_selector "button#past-tab.tw\\:hover\\:text-esperanto-600.tw\\:hover\\:border-esperanto-500\\/40"
    end
  end
end
