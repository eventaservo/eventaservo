# frozen_string_literal: true

require "application_system_test_case"

# Phase 3 Navbar guard: verifies rendering, brand, items, tools, and search in Lookbook.
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
end
