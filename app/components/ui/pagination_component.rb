# frozen_string_literal: true

module Ui
  # Renders accessible paging navigation styled with Tailwind CSS utilities.
  #
  # Consumes series, previous, next and URL helpers from a Pagy instance while
  # eliminating any dependency on legacy framework classes or markup.
  class PaginationComponent < ViewComponent::Base
    attr_reader :pagy, :show_single_page, :locale

    # Creates a paging component for a Pagy instance.
    #
    # @param pagy [Pagy, nil] the Pagy metadata object
    # @param aria_label [String, nil] custom aria-label for the nav landmark
    # @param show_single_page [Boolean] whether to render when total pages is 1
    # @param locale [Symbol, String, nil] optional locale override (defaults to I18n.locale)
    #
    # @return [Ui::PaginationComponent] the new component instance
    def initialize(pagy:, aria_label: nil, show_single_page: false, locale: nil)
      @pagy = pagy
      @custom_aria_label = aria_label
      @show_single_page = show_single_page
      @locale = locale
    end

    # Translates a key using the component's active locale.
    #
    # @param key [String, Symbol] translation key
    # @param options [Hash] translation interpolation options
    #
    # @return [String]
    def t(key, **options)
      I18n.t(key, locale: current_locale, **options)
    end

    # Returns the accessible landmark label evaluated in the active locale.
    #
    # @return [String]
    def aria_label
      @custom_aria_label || t("pagy.aria_label.nav", default: "Paĝa navigado")
    end

    # Determines if the component should be rendered.
    #
    # @return [Boolean] true when pagy is present and has multiple pages, or show_single_page is enabled
    def render?
      return false unless pagy

      show_single_page || pagy.last.to_i > 1
    end

    # Returns the list of series items: Integers for page links, Strings for current, and :gap.
    #
    # @return [Array<Integer, String, Symbol>]
    def series
      pagy.send(:series)
    end

    # Generates a link URL for a page number.
    #
    # @param page [Integer] target page number
    #
    # @return [String] generated URL
    def page_url(page)
      pagy.page_url(page)
    end

    # Returns whether a previous page exists.
    #
    # @return [Boolean]
    def prev?
      prev_page.present?
    end

    # Returns the previous page number if present.
    #
    # @return [Integer, nil]
    def prev_page
      pagy.respond_to?(:previous) ? pagy.previous : pagy.prev
    end

    # Returns the URL for the previous page.
    #
    # @return [String, nil]
    def prev_url
      page_url(prev_page) if prev?
    end

    # Returns whether a next page exists.
    #
    # @return [Boolean]
    def next?
      next_page.present?
    end

    # Returns the next page number if present.
    #
    # @return [Integer, nil]
    def next_page
      pagy.next
    end

    # Returns the URL for the next page.
    #
    # @return [String, nil]
    def next_url
      page_url(next_page) if next?
    end

    # Returns the localized label for the previous button.
    #
    # @return [ActiveSupport::SafeBuffer]
    def prev_label
      t("pagy.nav.prev", default: "&lsaquo;&nbsp;Antaŭa").html_safe
    end

    # Returns the localized label for the next button.
    #
    # @return [ActiveSupport::SafeBuffer]
    def next_label
      t("pagy.nav.next", default: "Sekva&nbsp;&rsaquo;").html_safe
    end

    # Returns the localized gap indicator text.
    #
    # @return [ActiveSupport::SafeBuffer]
    def gap_label
      t("pagy.nav.gap", default: "&hellip;").html_safe
    end

    private

    # Returns the active locale for this component.
    #
    # @return [Symbol, String]
    def current_locale
      @locale || I18n.locale
    end
  end
end
