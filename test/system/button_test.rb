# frozen_string_literal: true

require "application_system_test_case"

# Phase 3 ButtonComponent guard: verifies rendering, variants, icons, accessibility, and disabled states.
class ButtonTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin, :e2e_test_user)
    login_as(@admin)
  end

  test "renders all variants correctly in lookbook preview" do
    visit "/lookbook/preview/ui/button/all_variants"

    assert_selector "button", text: "Primary (Save)"
    assert_selector "button", text: "Success (New)"
    assert_selector "button", text: "Danger (Delete)"
    assert_selector "button", text: "Secondary"
    assert_selector "button", text: "Outline Primary"
    assert_selector "button", text: "Outline Danger"
    assert_selector "button", text: "New Link"
    assert_selector "button", text: "Cancel"
    assert_selector "button", text: "Delete"
  end

  test "renders leading and trailing icons with Font Awesome classes" do
    visit "/lookbook/preview/ui/button/with_icons"

    assert_selector "button i.fas.fa-arrow-left[aria-hidden='true']"
    assert_selector "button i.fas.fa-plus[aria-hidden='true']"
    assert_selector "button i.fas.fa-check[aria-hidden='true']"
    assert_selector "button i.fas.fa-trash[aria-hidden='true']"
    assert_selector "button i.fas.fa-arrow-right[aria-hidden='true']"
  end

  test "renders semantic links with valid hrefs in as_link preview" do
    visit "/lookbook/preview/ui/button/as_link"

    assert_selector "a[href='/']", text: /Reeniri/
    assert_selector "a[href='/e/new']", text: /Nova Evento/
    assert_selector "a[href='/']", text: /Nuligi/
  end

  test "verifies disabled states for both button and link variants" do
    visit "/lookbook/preview/ui/button/disabled_states"

    assert_selector "button[disabled]", text: "Primary"
    assert_selector "button[disabled]", text: "Success"
    assert_selector "button[disabled]", text: "Secondary"
    assert_selector "button[disabled]", text: "Cancel"
    assert_selector "button[disabled]", text: "Delete"

    assert_selector "a[role='link'][aria-disabled='true'][tabindex='-1']", text: "Primary Link"
    assert_selector "a[role='link'][aria-disabled='true'][tabindex='-1']", text: "Success Link"
    assert_no_selector "a[href='/save']"
    assert_no_selector "a[href='/new']"
  end

  test "renders canonical form footer layout with delete flush left" do
    visit "/lookbook/preview/ui/button/in_footer_context"

    assert_selector "button", text: "Forigi"
    assert_selector "button", text: "Nuligi"
    assert_selector "button[type='submit']", text: "Konservi Ŝanĝojn"
  end
end
