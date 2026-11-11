# frozen_string_literal: true

require "application_system_test_case"

# Phase 4 Step 1 Alert dismiss guard: verifies rendering, accessibility, and Stimulus dismiss interactions.
class AlertTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin, :e2e_test_user)
    login_as(@admin)
  end

  test "renders all color variants matching Bootstrap specifications 1:1" do
    visit "/lookbook/preview/ui/alert/all_variants"

    assert_selector "div[role='status']", text: /Informo:/
    assert_selector "div[role='status']", text: /Rimarko:/
    assert_selector "div[role='status']", text: /Sukceso:/
    assert_selector "div[role='status']", text: /Averto:/
    assert_selector "div[role='status']", text: /Eraro:/
    assert_selector "div[role='status']", text: /Neŭtrala:/
    assert_selector "div[role='status']", text: /Hela:/
  end

  test "renders icons preview with contextual FontAwesome icons" do
    visit "/lookbook/preview/ui/alert/with_icons"

    assert_selector "i.fa-info-circle"
    assert_selector "i.fa-check-circle"
    assert_selector "i.fa-exclamation-triangle"
    assert_selector "i.fa-exclamation-circle"
    assert_selector "i.fa-bell"
  end

  test "renders both medium and large sizes" do
    visit "/lookbook/preview/ui/alert/sizes"

    # Medium (system default)
    assert_selector "div.tw\\:py-2.tw\\:px-3.tw\\:text-sm", text: /Via konto estas sukcese agordita/
    # Large
    assert_selector "div.tw\\:py-3\\.5.tw\\:px-4.tw\\:text-base", text: /Gravaj prizorgaj laboroj okazos/
  end

  test "dismisses alert when close button is clicked" do
    visit "/lookbook/preview/ui/alert/dismissible"

    assert_selector "div[data-controller='dismissible']", text: /Ĉi tiu estas fermebla informo/

    # Click the first dismiss button
    first("button[data-action='dismissible#dismiss']").click

    # Alert should be removed from DOM
    assert_no_selector "div[data-controller='dismissible']", text: /Ĉi tiu estas fermebla informo/
  end

  test "dismisses alert when close button is activated via Enter key" do
    visit "/lookbook/preview/ui/alert/dismissible"

    assert_selector "div[data-controller='dismissible']", text: /Ĉi tiu estas fermebla informo/

    close_btn = first("button[data-action='dismissible#dismiss']")
    close_btn.send_keys(:enter)

    assert_no_selector "div[data-controller='dismissible']", text: /Ĉi tiu estas fermebla informo/
  end

  test "dismisses alert when Escape key is pressed while focused on the close button" do
    visit "/lookbook/preview/ui/alert/dismissible"

    assert_selector "div[data-controller='dismissible']", text: /Ĉi tiu estas fermebla informo/

    close_btn = first("button[data-action='dismissible#dismiss']")
    close_btn.send_keys(:escape)

    assert_no_selector "div[data-controller='dismissible']", text: /Ĉi tiu estas fermebla informo/
  end

  test "renders floating flash message with shadow and dismiss button" do
    visit "/lookbook/preview/ui/alert/flash_messages"

    assert_selector "div.flash-alert-box.tw\\:fixed.tw\\:top-10", text: /Evento sukcese konservita kaj publikigita!/
    assert_selector "button[data-action='dismissible#dismiss']"

    # Click close button on flash message
    find("button[data-action='dismissible#dismiss']").click

    assert_no_selector "div.flash-alert-box"
  end

  test "dismisses floating flash message via Escape key" do
    visit "/lookbook/preview/ui/alert/flash_messages"

    assert_selector "div.flash-alert-box.tw\\:fixed.tw\\:top-10", text: /Evento sukcese konservita kaj publikigita!/

    close_btn = find("button[data-action='dismissible#dismiss']")
    close_btn.send_keys(:escape)

    assert_no_selector "div.flash-alert-box"
  end
end
