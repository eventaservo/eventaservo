# frozen_string_literal: true

require "application_system_test_case"

# Phase 3 Form Controls guard: verifies rendering, sizes, interactions, and validation states.
class FormControlsTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin, :e2e_test_user)
    login_as(@admin)
  end

  test "renders input component sizes in lookbook" do
    visit "/lookbook/preview/ui/input/sizes"

    assert_selector "input.tw\\:py-1.tw\\:text-xs"
    assert_selector "input.tw\\:py-1\\.5.tw\\:text-sm"
  end

  test "renders input component icons in lookbook" do
    visit "/lookbook/preview/ui/input/with_icons"

    assert_selector "i.fa-search[aria-hidden='true']"
    assert_selector "i.fa-calendar-alt[aria-hidden='true']"
    assert_selector "i.fa-user[aria-hidden='true']"
    assert_selector "i.fa-lock[aria-hidden='true']"
  end

  test "renders input component states in lookbook" do
    visit "/lookbook/preview/ui/input/states"

    assert_selector "input[disabled]"
    assert_selector "input[readonly]"
    assert_selector "input[aria-invalid='true']"
    assert_selector "p", text: /La retpoŝtadreso ne estas valida formato/
  end

  test "renders select component default options in lookbook" do
    visit "/lookbook/preview/ui/select/default"

    assert_selector "select#select_country_id"
    assert_selector "select#select_country_id option", text: "Brazilo", visible: :all
    assert_selector "div.tw\\:pointer-events-none i.fa-chevron-down"
  end

  test "renders select component sizes in lookbook" do
    visit "/lookbook/preview/ui/select/sizes"

    assert_selector "select.tw\\:text-xs"
    assert_selector "select.tw\\:text-sm"
  end

  test "renders select component states in lookbook" do
    visit "/lookbook/preview/ui/select/states"

    assert_selector "select[disabled]"
    assert_selector "select[aria-invalid='true']"
    assert_selector "p", text: /Bonvolu elekti validan landon el la listo/
  end

  test "renders textarea component sizes in lookbook" do
    visit "/lookbook/preview/ui/textarea/sizes"

    assert_selector "textarea.tw\\:text-xs"
    assert_selector "textarea.tw\\:text-sm"
  end

  test "renders textarea component states in lookbook" do
    visit "/lookbook/preview/ui/textarea/states"

    assert_selector "textarea[disabled]"
    assert_selector "textarea[aria-invalid='true']"
    assert_selector "p", text: /La priskribo devas enhavi minimume 50 signojn/
  end

  test "renders checkbox component sizes in lookbook" do
    visit "/lookbook/preview/ui/checkbox/sizes"

    assert_selector "input.tw\\:custom-checkbox.tw\\:w-3\\.5.tw\\:h-3\\.5"
    assert_selector "input.tw\\:custom-checkbox.tw\\:w-4.tw\\:h-4"
  end

  test "renders checkbox component states and handles toggle interaction in lookbook" do
    visit "/lookbook/preview/ui/checkbox/states"

    assert_selector "input#checkbox_subscribe:not([checked])"
    assert_selector "input#checkbox_active[checked]"
    assert_selector "input#checkbox_disabled_unchecked[disabled]"
    assert_selector "input#checkbox_required_terms[aria-invalid='true']"
    assert_selector "p", text: /Vi devas konfirmi ĉi tiun punkton por daŭrigi/

    # Toggle checkbox
    checkbox = find("#checkbox_subscribe")
    assert_not checkbox.checked?
    checkbox.click
    assert checkbox.checked?
  end

  test "interacts with integrated form example in lookbook" do
    visit "/lookbook/preview/ui/form_example/default"

    fill_in "input_event_title", with: "Zamenhofa Tago 2026"
    select "Prelego", from: "select_category"
    fill_in "textarea_description", with: "Solena festado de la Zamenhofa Tago kun prelegoj kaj muziko."
    check "checkbox_online"

    assert_field "input_event_title", with: "Zamenhofa Tago 2026"
    assert_field "textarea_description", with: "Solena festado de la Zamenhofa Tago kun prelegoj kaj muziko."
    assert_checked_field "checkbox_international"
    assert_checked_field "checkbox_online"
  end
end
