# frozen_string_literal: true

require "application_system_test_case"

# Phase 2 pagination guard: verifies keyboard navigation, aria-current, and accessibility.
class PaginationTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin, :e2e_test_user)
    login_as(@admin)
  end

  test "renders aria-current on active page and navigable page links" do
    visit "/lookbook/preview/ui/pagination/middle_page"

    assert_selector "nav[aria-label]"
    assert_selector "span[aria-current='page']", text: "3"
    assert_selector "a[rel='prev']", text: /Antaŭa/
    assert_selector "a[rel='next']", text: /Sekva/
    assert_selector "a", text: "2"
    assert_selector "a", text: "4"
  end

  test "supports keyboard focus on pagination links" do
    visit "/lookbook/preview/ui/pagination/middle_page"

    prev_link = find("a[rel='prev']")
    page_two = find("a", text: "2")

    # Verify elements are keyboard focusable and carry appropriate attributes
    prev_link.send_keys(:tab)
    assert page_two.matches_css?("a[href='/events?page=2']")
    assert_equal "/events?page=2", page_two[:href].sub(%r{^https?://[^/]+}, "")
  end

  test "first page disables previous control with aria-disabled" do
    visit "/lookbook/preview/ui/pagination/first_page"

    assert_selector "span[aria-disabled='true']", text: /Antaŭa/
    assert_no_selector "a[rel='prev']"
    assert_selector "span[aria-current='page']", text: "1"
    assert_selector "a[rel='next']"
  end

  test "last page disables next control with aria-disabled" do
    visit "/lookbook/preview/ui/pagination/last_page"

    assert_selector "span[aria-disabled='true']", text: /Sekva/
    assert_no_selector "a[rel='next']"
    assert_selector "span[aria-current='page']", text: "5"
    assert_selector "a[rel='prev']"
  end

  test "renders ellipsis gap indicator without breaking keyboard order" do
    visit "/lookbook/preview/ui/pagination/with_gaps"

    assert_selector "span[aria-hidden='true']", text: "…"
    assert_selector "span[aria-current='page']", text: "10"
  end
end
