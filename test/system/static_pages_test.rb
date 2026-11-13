# frozen_string_literal: true

require "application_system_test_case"

class StaticPagesTest < ApplicationSystemTestCase
  test "renders privacy and terms pages inside prose cards without horizontal overflow" do
    ["/privateco", "/terms"].each do |path|
      visit path
      assert_selector ".tailwind-prose h1"
      assert_no_horizontal_overflow(width: 375)
      assert_no_horizontal_overflow(width: 1280)
    end

    visit "/privateco"
    decoration = evaluate_script(
      "getComputedStyle(document.querySelector('.tailwind-prose a')).textDecorationLine"
    )
    assert_equal "underline", decoration
  end

  test "renders about page sections cleanly across mobile, tablet, and desktop" do
    visit "/prie"
    assert_selector "h1", text: "Eventa Servo"
    assert_selector "img[src*='mapo']"
    assert_selector "img[src*='kalendaro']"
    assert_selector "img[src*='mobile']"

    [375, 768, 1280].each do |width|
      assert_no_horizontal_overflow(width: width)
    end
  end

  test "renders error pages and internal error feedback form without horizontal overflow" do
    ["/404", "/422"].each do |path|
      visit path
      assert_selector "h1"
      assert_selector "a", text: I18n.t("errors.not_found.back_to_home")
      assert_no_horizontal_overflow(width: 375)
      assert_no_horizontal_overflow(width: 1280)
    end

    visit "/500"
    assert_selector "h1", text: I18n.t("errors.internal_error.title")
    assert_selector "input[name='name'][required]"
    assert_selector "input[name='email'][required]"
    assert_selector "textarea[name='comments'][required]"
    assert_selector "button[type='submit']", text: I18n.t("errors.internal_error.form.submit")
    assert_no_horizontal_overflow(width: 375)
    assert_no_horizontal_overflow(width: 1280)
  end

  private

  # Resizes the browser viewport and verifies the page has no horizontal overflow.
  #
  # @param width [Integer] viewport width in pixels
  # @return [void]
  def assert_no_horizontal_overflow(width:)
    page.current_window.resize_to(width, 900)
    scroll_width = evaluate_script("document.documentElement.scrollWidth")
    client_width = evaluate_script("document.documentElement.clientWidth")
    assert_operator scroll_width, :<=, client_width,
      "Expected no horizontal overflow at #{width}px (scrollWidth=#{scroll_width}, clientWidth=#{client_width})"
  end
end
