# frozen_string_literal: true

require "application_system_test_case"

# Phase 3 Cards guard: verifies rendering, sizes, variants, media, slots, and interactive states.
class CardTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin, :e2e_test_user)
    login_as(@admin)
  end

  test "renders default card playground in lookbook" do
    visit "/lookbook/preview/ui/card/default"

    assert_selector "div.tw\\:bg-white.tw\\:rounded-lg"
    assert_selector "h3", text: "Esperanto-Kongreso 2026"
    assert_selector "p", text: "Universala Esperanto-Asocio"
  end

  test "renders all card variants in lookbook" do
    visit "/lookbook/preview/ui/card/all_variants"

    assert_selector "div.tw\\:shadow-sm", text: /Default Surface/
    assert_selector "div.tw\\:shadow-none", text: /Bordered/
    assert_selector "div.tw\\:shadow-md", text: /Elevated/
    assert_selector "div.tw\\:border-t-brand-blue", text: /Primary Accent/
    assert_selector "div.tw\\:border-t-esperanto-500", text: /Esperanto Accent/
    assert_selector "div.tw\\:cursor-pointer", text: /Interactive/
  end

  test "renders small and medium card sizes in lookbook" do
    visit "/lookbook/preview/ui/card/sizes"

    assert_selector "div.tw\\:p-3\\.5"
    assert_selector "div.tw\\:p-5"
    assert_selector "h3.tw\\:text-base", text: "Kopenhago Esperanto-Klubo"
    assert_selector "h3.tw\\:text-lg", text: "Kopenhago Esperanto-Klubo"
  end

  test "renders card with media in lookbook" do
    visit "/lookbook/preview/ui/card/with_media"

    assert_selector "div.tw\\:aspect-video img"
    assert_selector "div.tw\\:aspect-square img"
    assert_selector "h3", text: "111-a Universala Kongreso"
  end

  test "renders horizontal card orientation in lookbook" do
    visit "/lookbook/preview/ui/card/horizontal"

    assert_selector "div.tw\\:flex.tw\\:flex-col.md\\:tw\\:flex-row"
    assert_selector "h4", text: "Tutmonda Esperanta Junulara Kongreso"
  end

  test "renders structured card slots in lookbook" do
    visit "/lookbook/preview/ui/card/structured_slots"

    assert_selector "h3", text: "San-Paŭla Esperanto-Klubo"
    assert_selector "div.tw\\:border-b"
    assert_selector "div.tw\\:border-t"
    assert_selector "span", text: "Aktiva"
  end

  test "renders interactive card link in lookbook" do
    visit "/lookbook/preview/ui/card/interactive_link"

    assert_selector "a[href='https://gresillon.org']"
    assert_selector "h3", text: "Esperanto-Kulturdomo de Kastelo Greziljono"
  end

  test "renders admin mockup card examples in lookbook" do
    visit "/lookbook/preview/ui/card/mockup_examples"

    assert_selector "h4", text: "Karlo Markso"
    assert_selector "h4", text: "Anna Lowenstein"
    assert_selector "div.tw\\:border-t-brand-blue"
    assert_selector "div.tw\\:border-t-esperanto-500"
  end
end
