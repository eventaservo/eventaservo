# frozen_string_literal: true

require "application_system_test_case"

# Phase 4 Step 4 Tabs guard: verifies Stimulus WAI-ARIA tab switching, roving tabindex,
# ArrowLeft/ArrowRight/Home/End keyboard navigation, and organization tabs migration.
class TabsTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin, :e2e_test_user)
    login_as(@admin)
  end

  test "switches lookbook tabs on click with WAI-ARIA attributes" do
    visit "/lookbook/preview/ui/tabs/default"

    info_tab = find("#informoj-tab")
    program_tab = find("#programo-tab")
    participants_tab = find("#partoprenantoj-tab")

    assert_equal "true", info_tab["aria-selected"]
    assert_equal "0", info_tab["tabindex"]
    assert_equal "false", program_tab["aria-selected"]
    assert_equal "-1", program_tab["tabindex"]

    assert_selector "#informoj-panel", visible: true, text: "Ĝeneralaj informoj"
    assert_not find("#programo-panel", visible: :all).visible?
    assert_not find("#partoprenantoj-panel", visible: :all).visible?

    program_tab.click
    assert_equal "false", info_tab["aria-selected"]
    assert_equal "-1", info_tab["tabindex"]
    assert_equal "true", program_tab["aria-selected"]
    assert_equal "0", program_tab["tabindex"]
    assert_not find("#informoj-panel", visible: :all).visible?
    assert_selector "#programo-panel", visible: true, text: "Prelegoj, ekskursoj"

    participants_tab.click
    assert_equal "true", participants_tab["aria-selected"]
    assert_equal "0", participants_tab["tabindex"]
    assert_selector "#partoprenantoj-panel", visible: true, text: "Listo de aliĝintaj"
  end

  test "supports ArrowRight, ArrowLeft, Home, and End keyboard navigation in lookbook" do
    visit "/lookbook/preview/ui/tabs/with_counts"

    future_tab = find("#future-tab")
    past_tab = find("#past-tab")
    reports_tab = find("#reports-tab")

    future_tab.click
    assert_equal "true", future_tab["aria-selected"]

    # ArrowRight activates next tab and moves focus
    future_tab.send_keys(:arrow_right)
    assert_equal "true", past_tab["aria-selected"]
    assert_equal "0", past_tab["tabindex"]
    assert_equal "-1", future_tab["tabindex"]
    assert_selector "#past-panel", visible: true, text: "Pasintaj eventoj en la arkivo"
    assert page.evaluate_script("document.activeElement === arguments[0]", past_tab.native)

    # ArrowRight again moves to third tab
    past_tab.send_keys(:arrow_right)
    assert_equal "true", reports_tab["aria-selected"]
    assert_selector "#reports-panel", visible: true, text: "Fotoj kaj raportoj"
    assert page.evaluate_script("document.activeElement === arguments[0]", reports_tab.native)

    # ArrowRight wraps around to first tab
    reports_tab.send_keys(:arrow_right)
    assert_equal "true", future_tab["aria-selected"]
    assert_selector "#future-panel", visible: true, text: "Venontaj eventoj organizataj"
    assert page.evaluate_script("document.activeElement === arguments[0]", future_tab.native)

    # ArrowLeft wraps around to last tab
    future_tab.send_keys(:arrow_left)
    assert_equal "true", reports_tab["aria-selected"]
    assert_selector "#reports-panel", visible: true
    assert page.evaluate_script("document.activeElement === arguments[0]", reports_tab.native)

    # Home jumps to first tab; End jumps to last tab
    reports_tab.send_keys(:home)
    assert_equal "true", future_tab["aria-selected"]
    assert page.evaluate_script("document.activeElement === arguments[0]", future_tab.native)

    future_tab.send_keys(:end)
    assert_equal "true", reports_tab["aria-selected"]
    assert page.evaluate_script("document.activeElement === arguments[0]", reports_tab.native)
  end

  test "switches organization page tabs via click and keyboard using Stimulus" do
    organization = organizations(:rotterdam_centre)
    visit organization_path(short_name: organization.short_name)

    assert_selector "#orgTabs"
    future_tab = find("#future-tab")
    past_tab = find("#past-tab")
    reports_tab = find("#reports-tab")

    past_tab.click
    assert_equal "true", past_tab["aria-selected"]
    assert_selector "#past-tab-pane.show.active"
    assert_no_selector "#future-tab-pane.show.active"

    past_tab.send_keys(:arrow_right)
    assert_equal "true", reports_tab["aria-selected"]
    assert_selector "#reports-tab-pane.show.active"
    assert page.evaluate_script("document.activeElement === arguments[0]", reports_tab.native)

    reports_tab.send_keys(:arrow_right)
    assert_equal "true", future_tab["aria-selected"]
    assert_selector "#future-tab-pane.show.active"
    assert page.evaluate_script("document.activeElement === arguments[0]", future_tab.native)
  end

  test "preserves server-selected non-first tab on organization page" do
    organization = organizations(:rotterdam_centre)
    visit organization_path(short_name: organization.short_name, tab: "past")

    assert_selector "#past-tab.active[aria-selected='true'][tabindex='0']"
    assert_selector "#future-tab[aria-selected='false'][tabindex='-1']"
    assert_selector "#past-tab-pane.show.active"
    assert_no_selector "#future-tab-pane.show.active"

    visit organization_path(short_name: organization.short_name, tab: "reports")

    assert_selector "#reports-tab.active[aria-selected='true'][tabindex='0']"
    assert_selector "#future-tab[aria-selected='false'][tabindex='-1']"
    assert_selector "#reports-tab-pane.show.active"
    assert_no_selector "#future-tab-pane.show.active"
  end
end
