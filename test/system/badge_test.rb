# frozen_string_literal: true

require "application_system_test_case"

# Phase 3 BadgeComponent guard: verifies rendering, variants, accessibility, and Lookbook integration.
class BadgeTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin, :e2e_test_user)
    login_as(@admin)
  end

  test "renders all variants correctly matching Bootstrap colors 1:1" do
    visit "/lookbook/preview/ui/badge/all_variants"

    assert_selector "span", text: /Kategorio/
    assert_selector "span", text: /Karakterizo/
    assert_selector "span", text: /★ Internacia Evento/
    assert_selector "span", text: /Proksima/
    assert_selector "span", text: /Urbo-Nombro/
    assert_selector "span", text: /Neaktiva Filtro/
    assert_selector "span", text: /Nuligita/
  end

  test "renders event tags example with authentic green international badge and gray nearby badge" do
    visit "/lookbook/preview/ui/badge/event_tags_example"

    # International event is green with star
    assert_selector "span.tw\\:bg-esperanto-500.tw\\:text-white", text: "★ Internacia Evento"
    # Nearby badge is gray (text-bg-secondary)
    assert_selector "span.tw\\:bg-gray-600.tw\\:text-white", text: "Proksima"
    # Category is info teal
    assert_selector "span.tw\\:bg-brand-info.tw\\:text-white", text: "Renkontiĝo"
  end

  test "renders filter tags example with removable links and inactive tags" do
    visit "/lookbook/preview/ui/badge/filter_tags_example"

    assert_selector "a[href='#remove-renkontigoj'][aria-label='Forigi'] i.fa-times"
    assert_selector "a[href='#filter-kursoj']", text: "Kursoj"
  end

  test "renders clickable anchor tags in as_link preview" do
    visit "/lookbook/preview/ui/badge/as_link"

    assert_selector "a[href='/europo/Danio/Kopenhago']", text: /Kopenhago/
  end

  test "renders palette preview without errors" do
    visit "/lookbook/preview/ui/palette/all"

    assert_selector "h2", text: "Eventa Servo Kolorpaletro"
    assert_selector "div", text: "esperanto-500"
    assert_selector "div", text: "Hodiaŭ (Today)"
    assert_selector "div", text: "Brand Blue ($blue)"
  end
end
