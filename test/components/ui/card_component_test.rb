# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based Ui::CardComponent.
  class CardComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "renders basic panel with block content" do
      render_inline(Ui::CardComponent.new) { "Baza enhavo" }

      assert_selector "div.tw\\:bg-white.tw\\:rounded-lg.tw\\:overflow-hidden", text: "Baza enhavo"
      assert_selector "div.tw\\:p-5", text: "Baza enhavo"
    end

    test "renders shorthand title and subtitle without slots" do
      render_inline(
        Ui::CardComponent.new(
          title: "Esperanto Klubo",
          subtitle: "Loka grupo"
        )
      ) { "Enhavo de la klubo" }

      assert_selector "h3.tw\\:text-lg.tw\\:font-semibold", text: "Esperanto Klubo"
      assert_selector "p.tw\\:text-sm.tw\\:text-gray-500", text: "Loka grupo"
      assert_selector "div.tw\\:p-5", text: "Enhavo de la klubo"
    end

    test "renders default variant with subtle border and shadow" do
      render_inline(Ui::CardComponent.new(variant: :default)) { "Testo" }

      assert_selector "div.tw\\:border.tw\\:border-gray-200.tw\\:shadow-sm"
    end

    test "renders bordered variant without shadow" do
      render_inline(Ui::CardComponent.new(variant: :bordered)) { "Testo" }

      assert_selector "div.tw\\:border.tw\\:border-gray-200.tw\\:shadow-none"
    end

    test "renders elevated variant with prominent shadow" do
      render_inline(Ui::CardComponent.new(variant: :elevated)) { "Testo" }

      assert_selector "div.tw\\:shadow-md"
    end

    test "renders interactive variant with hover lift and cursor pointer" do
      render_inline(Ui::CardComponent.new(variant: :interactive)) { "Testo" }

      assert_selector "div.tw\\:cursor-pointer.hover\\:tw\\:shadow-md"
    end

    test "renders accent_primary variant with top brand blue border" do
      render_inline(Ui::CardComponent.new(variant: :accent_primary)) { "Testo" }

      assert_selector "div.tw\\:border-t-4.tw\\:border-t-brand-blue"
    end

    test "renders accent_success variant with top Esperanto green border" do
      render_inline(Ui::CardComponent.new(variant: :accent_success)) { "Testo" }

      assert_selector "div.tw\\:border-t-4.tw\\:border-t-esperanto-500"
    end

    test "renders small size with compact padding and font scale" do
      render_inline(
        Ui::CardComponent.new(
          title: "Kompakta",
          subtitle: "Subteksto",
          size: :small
        )
      ) { "Malgranda enhavo" }

      assert_selector "h3.tw\\:text-base", text: "Kompakta"
      assert_selector "p.tw\\:text-xs", text: "Subteksto"
      assert_selector "div.tw\\:p-3\\.5", text: "Malgranda enhavo"
      assert_selector "div.tw\\:px-3\\.5.tw\\:py-2\\.5"
    end

    test "renders structured slots for header, body, and footer" do
      render_inline(Ui::CardComponent.new) do |c|
        c.with_header { "Propra Kapo" }
        c.with_body { "Propra Korpo" }
        c.with_footer { "Propra Piedo" }
      end

      assert_selector "div.tw\\:border-b", text: "Propra Kapo"
      assert_selector "div.tw\\:p-5", text: "Propra Korpo"
      assert_selector "div.tw\\:border-t", text: "Propra Piedo"
    end

    test "renders header slot with title and subtitle helpers" do
      render_inline(Ui::CardComponent.new) do |c|
        c.with_header(title: "Kap-titolo", subtitle: "Kap-subteksto", accent: :primary)
        c.with_body { "Enhavo" }
      end

      assert_selector "h3.tw\\:text-lg.tw\\:font-semibold", text: "Kap-titolo"
      assert_selector "p.tw\\:text-sm", text: "Kap-subteksto"
      assert_selector "div.tw\\:bg-blue-50\\/60.tw\\:border-blue-100"
    end

    test "renders media slot with image source and aspect ratio" do
      render_inline(Ui::CardComponent.new) do |c|
        c.with_media(src: "/test-image.jpg", alt: "Bildo", aspect_ratio: :video)
        c.with_body { "Enhavo" }
      end

      assert_selector "div.tw\\:aspect-video img[src='/test-image.jpg'][alt='Bildo']"
    end

    test "renders horizontal orientation layout" do
      render_inline(Ui::CardComponent.new(orientation: :horizontal)) do |c|
        c.with_media(src: "/side-image.jpg", alt: "Flanka Bildo")
        c.with_body { "Flanka enhavo" }
      end

      assert_selector "div.tw\\:flex.tw\\:flex-col.md\\:tw\\:flex-row"
      assert_selector "div.tw\\:w-full.md\\:tw\\:w-1\\/3.md\\:tw\\:shrink-0"
      assert_selector "div.tw\\:flex-1", text: "Flanka enhavo"
    end

    test "renders as anchor tag when href is provided" do
      render_inline(
        Ui::CardComponent.new(
          title: "Klaku ĉi tie",
          href: "https://eventaservo.org/e/123"
        )
      ) { "Ligo-enhavo" }

      assert_selector "a[href='https://eventaservo.org/e/123']"
      assert_selector "a.focus-visible\\:tw\\:ring-brand-blue"
    end

    test "renders custom semantic tag when specified" do
      render_inline(Ui::CardComponent.new(tag: :article)) { "Artikolo" }

      assert_selector "article.tw\\:bg-white", text: "Artikolo"
    end

    test "removes body padding when flush is true" do
      render_inline(Ui::CardComponent.new(flush: true)) { "Sen marĝeno" }

      assert_no_selector "div.tw\\:p-5"
      assert_selector "div.tw\\:flex-1", text: "Sen marĝeno"
    end

    test "allows overflowing content when overflow_visible is true" do
      render_inline(Ui::CardComponent.new(overflow_visible: true)) { "Falmenuo" }

      assert_selector "div.tw\\:overflow-visible", text: "Falmenuo"
      assert_no_selector "div.tw\\:overflow-hidden"
    end
  end
end
