# frozen_string_literal: true

require "application_system_test_case"

# Phase 4 Step 3 Dropdowns guard: verifies Stimulus menu behavior, ARIA attributes,
# keyboard navigation, focus management, and legacy view migrations.
class DropdownTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin, :e2e_test_user)
    login_as(@admin)
  end

  test "toggles lookbook menu on click and closes on outside click" do
    visit "/lookbook/preview/ui/dropdown/default"

    trigger = find("button[data-menu-target='button']")
    panel = find("div#preview-default-menu", visible: :all)

    assert_equal "false", trigger["aria-expanded"]
    assert_not panel.visible?

    trigger.click
    assert_equal "true", trigger["aria-expanded"]
    assert panel.visible?

    # Click outside closes the menu
    find("body").click
    assert_equal "false", trigger["aria-expanded"]
    assert_not panel.visible?
  end

  test "supports full keyboard navigation and Escape focus return in lookbook" do
    visit "/lookbook/preview/ui/dropdown/right_aligned"

    trigger = find("button[data-menu-target='button']")
    panel = find("div#preview-user-menu", visible: :all)
    items = panel.all("a[role='menuitem']", visible: :all)

    assert_equal 4, items.size

    # ArrowDown on trigger opens menu and focuses first item
    trigger.send_keys(:arrow_down)
    assert_equal "true", trigger["aria-expanded"]
    assert panel.visible?
    assert page.evaluate_script("document.activeElement === arguments[0]", items[0].native)

    # ArrowDown moves to second item
    items[0].send_keys(:arrow_down)
    assert page.evaluate_script("document.activeElement === arguments[0]", items[1].native)

    # End moves to last item
    items[1].send_keys(:end)
    assert page.evaluate_script("document.activeElement === arguments[0]", items[3].native)

    # ArrowUp moves to previous item
    items[3].send_keys(:arrow_up)
    assert page.evaluate_script("document.activeElement === arguments[0]", items[2].native)

    # Home moves back to first item
    items[2].send_keys(:home)
    assert page.evaluate_script("document.activeElement === arguments[0]", items[0].native)

    # Escape closes menu and returns focus to trigger button
    items[0].send_keys(:escape)
    assert_equal "false", trigger["aria-expanded"]
    assert_not panel.visible?
    assert page.evaluate_script("document.activeElement === arguments[0]", trigger.native)
  end

  test "opens and closes application footer, user, and language menus via Stimulus" do
    visit "/"

    # Footer menu
    footer_trigger = find("#footerMenu")
    assert_equal "false", footer_trigger["aria-expanded"]

    footer_trigger.click
    assert_selector "#footerMenu[aria-expanded='true']"
    assert_selector "#footerMenuPanel.show"

    footer_trigger.send_keys(:escape)
    assert_selector "#footerMenu[aria-expanded='false']"
    assert_no_selector "#footerMenuPanel.show"

    # Open mobile navbar drawer to interact with user & language menus
    find("button.navbar-toggler[data-toggle-target='button']", visible: :all).click
    assert_selector "#navbar-supported-content.show"

    # Language selector menu
    lang_trigger = find("#navbar-dropdown")
    lang_trigger.click
    assert_selector "#navbar-dropdown[aria-expanded='true']"
    assert_selector "#navbar-dropdown-menu.show"

    lang_trigger.send_keys(:escape)
    assert_selector "#navbar-dropdown[aria-expanded='false']"
    assert_no_selector "#navbar-dropdown-menu.show"

    # User profile menu
    user_trigger = find("#uzantoDropdown")
    user_panel = find("#uzantoDropdownMenu", visible: :all)
    user_trigger.click
    assert_selector "#uzantoDropdown[aria-expanded='true']"
    assert_selector "#uzantoDropdownMenu.show"

    user_trigger.send_keys(:arrow_down)
    assert_equal user_panel.first("a")[:href], page.evaluate_script("document.activeElement.href")

    page.evaluate_script("document.activeElement").send_keys(:escape)
    assert_selector "#uzantoDropdown[aria-expanded='false']"
    assert_no_selector "#uzantoDropdownMenu.show"
    assert page.evaluate_script("document.activeElement === arguments[0]", user_trigger.native)
  end
end
