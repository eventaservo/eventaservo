# frozen_string_literal: true

require "application_system_test_case"

# Phase 4 Step 6 Tooltips guard: verifies Stimulus hint behavior on hover,
# keyboard focus, Escape dismissal, ARIA linkage, placements, and migrated views.
class TooltipTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin, :e2e_test_user)
    login_as(@admin)
  end

  test "shows and dismisses Lookbook hint on hover, focus, and Escape with ARIA linkage" do
    visit "/lookbook/preview/ui/tooltip/default"

    trigger = find("[data-controller='hint']")
    assert_no_selector "[role='tooltip']"

    # Hover shows tooltip and links aria-describedby
    trigger.hover
    tip = find("[role='tooltip']", text: "Somertempo aktivas en tiu ĉi evento", visible: true)
    assert_equal tip[:id], trigger["aria-describedby"]

    # Move mouse away hides tooltip and clears aria-describedby
    find("body").hover
    assert_no_selector "[role='tooltip']"
    assert_nil trigger["aria-describedby"]

    # Keyboard focus shows tooltip and Escape dismisses it
    page.execute_script("arguments[0].focus()", trigger.native)
    tip = find("[role='tooltip']", text: "Somertempo aktivas en tiu ĉi evento", visible: true)
    assert_equal tip[:id], trigger["aria-describedby"]

    trigger.send_keys(:escape)
    assert_no_selector "[role='tooltip']"
    assert_nil trigger["aria-describedby"]
  end

  test "renders placement directions in Lookbook without overflowing viewport" do
    visit "/lookbook/preview/ui/tooltip/placements"

    find("[data-hint-placement-value='bottom']").hover
    assert_selector "[role='tooltip'][data-placement='bottom']", text: "Indiko malsupre", visible: true

    find("[data-hint-placement-value='right']").hover
    assert_selector "[role='tooltip'][data-placement='right']", text: "Indiko dekstre", visible: true
  end

  test "shows hints on navbar tool links and organization table headers" do
    page.current_window.resize_to(1280, 900)
    visit organizations_path

    navbar_link = first("nav a[data-controller='hint']")
    navbar_link.hover
    assert_selector "[role='tooltip'][data-placement='bottom']", visible: true
    navbar_link.send_keys(:escape)
    assert_no_selector "[role='tooltip']"

    header_hint = first("#o_search_results [data-controller='hint']")
    page.execute_script("arguments[0].focus()", header_hint.native)
    assert_selector "[role='tooltip']", text: I18n.t("common.events"), visible: true
    header_hint.send_keys(:escape)
    assert_no_selector "[role='tooltip']"
  ensure
    page.current_window.resize_to(530, 1170)
  end
end
