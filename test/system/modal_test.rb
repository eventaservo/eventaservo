# frozen_string_literal: true

require "application_system_test_case"

# Phase 4 Step 5 Modals guard: verifies native <dialog> Stimulus behavior,
# focus trap, Escape/backdrop/button closing, focus return, and app modal migrations.
class ModalTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin, :e2e_test_user)
    login_as(@admin)
  end

  test "renders Lookbook default dialog open on load and closes via close button" do
    visit "/lookbook/preview/ui/modal/default"

    assert_selector "dialog#preview-default-dialog[open]", visible: true
    assert_selector "#preview-default-dialogTitle", text: "Kunhavigi eventon"

    find("dialog#preview-default-dialog button[aria-label]").click
    assert_no_selector "dialog#preview-default-dialog[open]"
  end

  test "opens Lookbook dialog, traps Tab focus, closes via button, backdrop, and Escape with focus return" do
    visit "/lookbook/preview/ui/modal/default?open=false"

    trigger = find("button[data-dialog-open='preview-default-dialog']")
    assert_no_selector "dialog#preview-default-dialog[open]"

    trigger.click
    assert_selector "dialog#preview-default-dialog[open]", visible: true
    assert_selector "#preview-default-dialogTitle", text: "Kunhavigi eventon"

    # Tab cycles between the header close button and footer close button inside dialog
    header_close = find("dialog#preview-default-dialog button[aria-label]")
    footer_close = find("dialog#preview-default-dialog button", text: "Fermi")

    assert page.evaluate_script("document.activeElement === arguments[0]", header_close.native)
    header_close.send_keys(:tab)
    assert page.evaluate_script("document.activeElement === arguments[0]", footer_close.native)
    footer_close.send_keys(:tab)
    assert page.evaluate_script("document.activeElement === arguments[0]", header_close.native)
    header_close.send_keys(%i[shift tab])
    assert page.evaluate_script("document.activeElement === arguments[0]", footer_close.native)

    # Escape closes dialog and restores focus to trigger
    footer_close.send_keys(:escape)
    assert_no_selector "dialog#preview-default-dialog[open]"
    assert page.evaluate_script("document.activeElement === arguments[0]", trigger.native)

    # Re-open and close via backdrop click outside dialog bounds
    trigger.click
    assert_selector "dialog#preview-default-dialog[open]", visible: true
    page.execute_script(<<~JS)
      const dialog = document.getElementById("preview-default-dialog");
      dialog.dispatchEvent(new MouseEvent("click", { bubbles: true, clientX: 5, clientY: 5 }));
    JS
    assert_no_selector "dialog#preview-default-dialog[open]"
    assert page.evaluate_script("document.activeElement === arguments[0]", trigger.native)

    # Re-open and close via close button
    trigger.click
    find("dialog#preview-default-dialog button", text: "Fermi").click
    assert_no_selector "dialog#preview-default-dialog[open]"
    assert page.evaluate_script("document.activeElement === arguments[0]", trigger.native)
  end

  test "opens Lookbook form dialog and allows form input interaction" do
    visit "/lookbook/preview/ui/modal/form?open=false"

    find("button[data-dialog-open='preview-form-dialog']").click
    assert_selector "dialog#preview-form-dialog[open]", visible: true

    fill_in "Nomo", with: "Zamenhof"
    fill_in "Mesaĝo", with: "Testa mesaĝo"
    find("dialog#preview-form-dialog button", text: "Nuligi").click

    assert_no_selector "dialog#preview-form-dialog[open]"
  end

  test "opens Share and Report Problem dialogs on event page and focuses message field" do
    event = events(:valid_event)
    visit event_path(code: event.code)

    find("a[data-dialog-open='shareModal']").click
    assert_selector "dialog#shareModal[open]", visible: true
    assert_selector "#shareModalCenterTitle"
    find("dialog#shareModal button[data-action='dialog#close']", text: I18n.t("buttons.close")).click
    assert_no_selector "dialog#shareModal[open]"

    find("a[data-dialog-open='reportProblemModal']").click
    assert_selector "dialog#reportProblemModal[open]", visible: true
    assert page.evaluate_script(
      "document.activeElement === document.querySelector('#reportProblemModal textarea[name=\"message\"]')"
    )
    find("dialog#reportProblemModal button[data-action='dialog#close']", text: I18n.t("buttons.cancel")).click
    assert_no_selector "dialog#reportProblemModal[open]"
  end

  test "opens Timezone dialog with SlimSelect rendered inside dialog top layer" do
    visit root_path

    trigger = find("#select-timezone-link")
    trigger.click

    assert_selector "dialog#timezoneModal[open]", visible: true
    assert page.evaluate_script("document.activeElement === document.getElementById('timezoneModal')")

    # SlimSelect content mounts inside the dialog controller subtree rather than document.body
    assert_selector "dialog#timezoneModal .ss-main"
    find("dialog#timezoneModal .ss-main").click
    assert_selector "dialog#timezoneModal .ss-content.ss-open-below, dialog#timezoneModal .ss-content.ss-open-above", visible: true

    find("dialog#timezoneModal").send_keys(:escape)
    assert_no_selector "dialog#timezoneModal[open]"
    assert page.evaluate_script("document.activeElement === arguments[0]", trigger.native)
  end

  test "opens Webcal dialog on organization page" do
    organization = organizations(:rotterdam_centre)
    visit organization_path(short_name: organization.short_name)

    find("a[data-dialog-open='webcalModal']").click
    assert_selector "dialog#webcalModal[open]", visible: true
    assert_selector "#webcalModal #shareModalCenterTitle"
    find("dialog#webcalModal button[data-action='dialog#close'][aria-label]").click
    assert_no_selector "dialog#webcalModal[open]"
  end
end
