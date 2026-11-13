# frozen_string_literal: true

require "application_system_test_case"

# Phase 4 Step 2 Navbar guard: verifies rendering, responsive mobile drawer, and Stimulus toggle interactions.
class NavbarTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin, :e2e_test_user)
    login_as(@admin)
  end

  test "renders default navigation bar in lookbook" do
    visit "/lookbook/preview/ui/navbar/default"

    assert_selector "nav.tw\\:bg-esperanto-500.tw\\:text-white"
    assert_selector "a", text: "Eventa Servo"
    assert_selector "a", text: "Aldoni eventon", visible: :all
    assert_selector "a", text: "Organizaĵoj", visible: :all
    assert_selector "input[type='search']", visible: :all
  end

  test "renders logged in navigation bar with user profile in lookbook" do
    visit "/lookbook/preview/ui/navbar/logged_in"

    assert_selector "span", text: "STAGING"
    assert_selector "span", text: "Fernando"
    assert_no_selector "span", text: "Admin"
    assert_selector "a.tw\\:bg-esperanto-700", text: "Aldoni eventon", visible: :all
  end

  test "renders navigation bar with active tools in lookbook" do
    visit "/lookbook/preview/ui/navbar/with_active_tools"

    assert_selector "a.tw\\:bg-yellow-400[aria-label='Fermi mapon']", visible: :all
    assert_selector "i.fa-telegram, i.fa-newspaper", visible: :all
  end

  test "renders mobile navigation bar view in lookbook" do
    visit "/lookbook/preview/ui/navbar/mobile_view"

    assert_selector "button[aria-label='Navigado']"
    assert_selector "a", text: "Eventa Servo"
  end

  test "toggles mobile drawer open and closed in lookbook" do
    visit "/lookbook/preview/ui/navbar/default"

    toggle_btn = find("button[aria-label='Navigado']", visible: :all)
    assert_equal "false", toggle_btn["aria-expanded"]

    # Open mobile drawer
    toggle_btn.click
    assert_equal "true", toggle_btn["aria-expanded"]
    assert_selector "i.fa-times", visible: :all

    # Close mobile drawer
    toggle_btn.click
    assert_equal "false", toggle_btn["aria-expanded"]
    assert_selector "i.fa-bars", visible: :all
  end

  test "closes mobile drawer via Escape key in lookbook" do
    visit "/lookbook/preview/ui/navbar/default"

    toggle_btn = find("button[aria-label='Navigado']", visible: :all)
    toggle_btn.click
    assert_equal "true", toggle_btn["aria-expanded"]

    # Press Escape key
    toggle_btn.send_keys(:escape)
    assert_equal "false", toggle_btn["aria-expanded"]
  end

  test "toggles application navbar on mobile viewport via Stimulus" do
    visit "/"

    toggler = find("button.navbar-toggler[data-toggle-target='button']", visible: :all)
    assert_equal "false", toggler["aria-expanded"]
    assert_no_selector "#navbar-supported-content.show", visible: :all

    # Click to expand
    toggler.click
    assert_equal "true", toggler["aria-expanded"]
    assert_selector "#navbar-supported-content.show", visible: :all

    # Press Escape to close
    toggler.send_keys(:escape)
    assert_equal "false", toggler["aria-expanded"]
    assert_no_selector "#navbar-supported-content.show", visible: :all
  end

  test "keeps brand and toggler on the same row on mobile viewport without wrapping" do
    visit "/"

    brand = find(".navbar-brand", visible: :all)
    toggler = find("button.navbar-toggler", visible: :all)

    # In mobile view, toggler should be vertically aligned with brand (not wrapped to a second line)
    assert_in_delta brand.rect.y, toggler.rect.y, 16
  end
end
