# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

module Ui
  # Unit tests for the Tailwind-based pagination ViewComponent.
  class PaginationComponentTest < ActionView::TestCase
    include ViewComponent::TestHelpers

    test "does not render when pagy is nil" do
      render_inline(Ui::PaginationComponent.new(pagy: nil))

      assert_no_selector "nav"
    end

    test "does not render when total pages is 1 unless show_single_page is enabled" do
      pagy = build_pagy(count: 10, page: 1)

      render_inline(Ui::PaginationComponent.new(pagy:))
      assert_no_selector "nav"

      render_inline(Ui::PaginationComponent.new(pagy:, show_single_page: true))
      assert_selector "nav[aria-label]"
      assert_selector "span[aria-current='page']", text: "1"
    end

    test "renders active page with aria-current and esperanto green style" do
      pagy = build_pagy(count: 60, page: 2)

      render_inline(Ui::PaginationComponent.new(pagy:))

      assert_selector "span[aria-current='page']", text: "2"
      assert_selector "span.tw\\:bg-esperanto-600.tw\\:text-white", text: "2"
    end

    test "renders navigable links for inactive pages" do
      pagy = build_pagy(count: 60, page: 2)

      render_inline(Ui::PaginationComponent.new(pagy:))

      assert_selector "a[href='/events?page=1']", text: "1"
      assert_selector "a[href='/events?page=3']", text: "3"
      assert_selector "a[href='/events?page=4']", text: "4"
    end

    test "disables previous button on first page" do
      pagy = build_pagy(count: 60, page: 1)

      render_inline(Ui::PaginationComponent.new(pagy:))

      assert_selector "span[aria-disabled='true']", text: /Antaŭa/
      assert_no_selector "a[rel='prev']"
      assert_selector "a[rel='next'][href='/events?page=2']"
    end

    test "enables previous button as link on middle and last pages" do
      pagy = build_pagy(count: 60, page: 3)

      render_inline(Ui::PaginationComponent.new(pagy:))

      assert_selector "a[rel='prev'][href='/events?page=2']"
      assert_selector "a[rel='next'][href='/events?page=4']"
    end

    test "disables next button on last page" do
      pagy = build_pagy(count: 60, page: 4)

      render_inline(Ui::PaginationComponent.new(pagy:))

      assert_selector "span[aria-disabled='true']", text: /Sekva/
      assert_no_selector "a[rel='next']"
      assert_selector "a[rel='prev'][href='/events?page=3']"
    end

    test "renders gap separators when series contains ellipsis" do
      pagy = build_pagy(count: 300, page: 10)

      render_inline(Ui::PaginationComponent.new(pagy:))

      assert_selector "span[aria-hidden='true']", text: "…"
    end

    test "respects active locale for navigation labels and aria descriptions" do
      pagy = build_pagy(count: 60, page: 2)

      I18n.with_locale(:en) do
        render_inline(Ui::PaginationComponent.new(pagy:))
        assert_selector "nav[aria-label='Pagination']"
        assert_selector "a[rel='prev']", text: /Prev/
        assert_selector "a[rel='next']", text: /Next/
      end

      I18n.with_locale(:pt_BR) do
        render_inline(Ui::PaginationComponent.new(pagy:))
        assert_selector "nav[aria-label='Paginação']"
        assert_selector "a[rel='prev']", text: /Anterior/
        assert_selector "a[rel='next']", text: /Próximo/
      end

      # Also verifies explicit locale override parameter
      render_inline(Ui::PaginationComponent.new(pagy:, locale: :pt_BR))
      assert_selector "nav[aria-label='Paginação']"
      assert_selector "a[rel='prev']", text: /Anterior/
      assert_selector "a[rel='next']", text: /Próximo/
    end

    private

    # Builds a mock Pagy instance with a mock request for testing.
    #
    # @param count [Integer] total item count
    # @param page [Integer] current page
    # @param limit [Integer] items per page
    #
    # @return [Pagy::Offset]
    def build_pagy(count:, page:, limit: 15)
      mock_request = Struct.new(:params, :path, :base_url).new({}, "/events", "")
      Pagy::Offset.new(count:, page:, limit:, request: mock_request)
    end
  end
end
