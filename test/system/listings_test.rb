# frozen_string_literal: true

require "application_system_test_case"

# End-to-end tests for geographic, past, and calendar event listing pages.
class ListingsSystemTest < ApplicationSystemTestCase
  setup do
    @original_window_size = page.current_window.size
  end

  teardown do
    page.current_window.resize_to(*@original_window_size) if @original_window_size
  end

  test "continent, country, and city listings render breadcrumbs, filters, and cards without horizontal overflow" do
    country = countries(:afghanistan)
    upcoming_event = events(:valid_event)

    [
      events_by_continent_path(continent: country.continent.normalized),
      events_by_country_path(continent: country.continent.normalized, country_name: country.name.normalized),
      events_by_city_path(continent: country.continent.normalized, country_name: country.name.normalized, city_name: upcoming_event.city.normalized)
    ].each do |path|
      visit path
      assert_selector "nav[aria-label='breadcrumb'] li", text: I18n.t("breadcrumbs.world")
      assert_text upcoming_event.title

      [375, 768, 1280].each do |width|
        page.current_window.resize_to(width, 900)
        scroll_width = evaluate_script("document.documentElement.scrollWidth")
        client_width = evaluate_script("document.documentElement.clientWidth")
        assert_operator scroll_width, :<=, client_width,
          "Expected no horizontal overflow at #{width}px on #{path} (scrollWidth=#{scroll_width}, clientWidth=#{client_width})"
      end
    end
  end

  test "past event listings on country and city render past cards and upcoming toggle" do
    country = countries(:denmark)
    past_event = events(:past_event_danio_recent)

    visit events_by_country_path(continent: country.continent.normalized, country_name: country.name.normalized, pasintaj: 1)
    assert_selector "nav[aria-label='breadcrumb'] li", text: country.name
    assert_text past_event.title
    assert_selector "a", text: I18n.t("events.show_upcoming")

    visit events_by_city_path(continent: country.continent.normalized, country_name: country.name.normalized, city_name: past_event.city.normalized, pasintaj: 1)
    assert_text past_event.title
    assert_selector "a", text: I18n.t("events.show_upcoming")
  end

  test "by_country webcal modal opens from breadcrumb calendar trigger" do
    country = countries(:afghanistan)

    visit events_by_country_path(continent: country.continent.normalized, country_name: country.name.normalized)
    find("a[data-dialog-open='webcalModal']").click

    assert_selector "dialog#webcalModal[open]"
    assert_selector "dialog#webcalModal input[data-clipboard-target='source']"
  end

  test "reta calendar month menu is not clipped by the outer card on an empty week" do
    visit events_by_continent_path(continent: "reta", date: "2028-01-03")

    find("#calendarMonthNavigation").click
    assert_selector "#calendarMonthNavigationMenu.show", visible: true

    menu_rect = evaluate_script("document.getElementById('calendarMonthNavigationMenu').getBoundingClientRect()")
    last_item_rect = evaluate_script("document.querySelector('#calendarMonthNavigationMenu a:last-of-type').getBoundingClientRect()")
    card_overflow = evaluate_script("getComputedStyle(document.querySelector('.tw\\\\:overflow-visible')).overflow")

    assert_equal "visible", card_overflow
    assert_operator last_item_rect["bottom"], :<=, menu_rect["bottom"] + 1
    assert_operator last_item_rect["height"], :>, 20
  end

  test "calendar month menu stays within mobile and desktop viewports" do
    [375, 1280].each do |width|
      page.current_window.resize_to(width, 900)
      visit root_path

      find("#calendarMonthNavigation").click
      assert_selector "#calendarMonthNavigationMenu.show", visible: true

      menu_rect = evaluate_script("document.getElementById('calendarMonthNavigationMenu').getBoundingClientRect()")
      client_width = evaluate_script("document.documentElement.clientWidth")

      assert_operator menu_rect["left"], :>=, 0,
        "Expected month menu not to overflow left viewport edge at #{width}px (left=#{menu_rect["left"]})"
      assert_operator menu_rect["right"], :<=, client_width,
        "Expected month menu not to overflow right viewport edge at #{width}px (right=#{menu_rect["right"]}, clientWidth=#{client_width})"
    end
  end
end
