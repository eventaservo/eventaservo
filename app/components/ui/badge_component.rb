# frozen_string_literal: true

module Ui
  # Renders accessible badges and tags styled with Tailwind CSS utilities.
  #
  # Supports event categories and characteristics, active and inactive filters,
  # counts, special event badges (international, nearby), and removable tags
  # in pill or rounded formats.
  class BadgeComponent < ViewComponent::Base
    VARIANTS = {
      # Standard Bootstrap 1:1 color variants
      info: :info,
      category: :info,
      warning: :warning,
      characteristic: :warning,
      success: :success,
      primary: :primary,
      secondary: :secondary,
      neutral: :secondary,
      light: :light,
      inactive: :light,
      danger: :danger
    }.freeze

    SHAPES = {
      pill: :pill,
      rounded: :rounded
    }.freeze

    SIZES = {
      small: :small,
      medium: :medium,
      large: :large,
      # Convenience aliases
      xs: :small,
      sm: :medium,
      md: :large
    }.freeze

    attr_reader :variant, :shape, :size, :href, :icon_name, :icon_style,
      :icon_position, :text, :removable, :remove_href, :html_options

    # Creates a new tag component instance.
    #
    # @param text [String, nil] label text (or pass content block)
    # @param variant [Symbol] visual variant (:info, :warning, :success, :secondary,
    #   :light, :danger)
    # @param shape [Symbol] tag shape (:pill, :rounded; defaults to :pill)
    # @param size [Symbol] tag size (:small, :medium, :large; defaults to :medium)
    # @param href [String, nil] optional URL target; when present, renders an <a> tag
    # @param icon [String, Symbol, nil] Font Awesome icon name (e.g. "star", "times")
    # @param icon_style [String] Font Awesome style ("fas", "far", "fab"; defaults to "fas")
    # @param icon_position [Symbol] icon placement (:leading, :trailing; defaults to :leading)
    # @param removable [Boolean] whether to display a dismiss/remove icon
    # @param remove_href [String, nil] optional URL target for the remove action
    # @param html_options [Hash] additional HTML attributes
    #
    # @return [Ui::BadgeComponent]
    def initialize(
      text = nil,
      variant: :info,
      shape: :pill,
      size: :medium,
      href: nil,
      icon: nil,
      icon_style: "fas",
      icon_position: :leading,
      removable: false,
      remove_href: nil,
      **html_options
    )
      @text = text
      @variant = VARIANTS.fetch(variant.to_sym) { :info }
      @shape = SHAPES.fetch(shape.to_sym) { :pill }
      @size = SIZES.fetch(size.to_sym) { :medium }
      @href = href
      @icon_name = icon&.to_s
      @icon_style = icon_style
      @icon_position = icon_position.to_sym
      @removable = removable
      @remove_href = remove_href
      @html_options = html_options
    end

    # Determines whether this component renders as a link.
    #
    # @return [Boolean]
    def link?
      href.present?
    end

    # Returns the HTML tag name to render ("a" or "span").
    #
    # @return [String]
    def tag_name
      link? ? "a" : "span"
    end

    # Returns true if an icon should be rendered.
    #
    # @return [Boolean]
    def icon?
      icon_name.present?
    end

    # Returns true if the icon should precede the text content.
    #
    # @return [Boolean]
    def leading_icon?
      icon? && icon_position != :trailing
    end

    # Returns true if the icon should follow the text content.
    #
    # @return [Boolean]
    def trailing_icon?
      icon? && icon_position == :trailing
    end

    # Renders the Font Awesome icon element.
    #
    # @return [ActiveSupport::SafeBuffer]
    def render_icon
      tag.i(class: "#{icon_style} fa-#{icon_name}", aria: {hidden: "true"})
    end

    # Combines base, variant, shape, size, and caller-provided CSS classes.
    #
    # @return [String]
    def computed_classes
      [
        base_classes,
        shape_classes,
        size_classes,
        variant_classes,
        interactive_classes,
        html_options[:class]
      ].compact.join(" ")
    end

    # Merges all HTML attributes for the rendered element.
    #
    # @return [Hash]
    def element_attributes
      attrs = html_options.except(:class)
      attrs[:class] = computed_classes
      attrs[:href] = href if link?
      attrs
    end

    private

    # Base classes shared by all badges.
    #
    # @return [String]
    def base_classes
      "tw:inline-flex tw:items-center tw:gap-1.5 tw:font-medium " \
        "tw:leading-none tw:select-none tw:border tw:border-solid tw:no-underline"
    end

    # Shape utilities.
    #
    # @return [String]
    def shape_classes
      case shape
      when :rounded
        "tw:rounded-[3px]"
      else # :pill (default)
        "tw:rounded-full"
      end
    end

    # Size utilities.
    #
    # @return [String]
    def size_classes
      case size
      when :small
        "tw:text-[10px] tw:px-1.5 tw:py-0.5"
      when :large
        "tw:text-sm tw:px-3 tw:py-1"
      else # :medium (default)
        "tw:text-xs tw:px-2.5 tw:py-0.5"
      end
    end

    # Color and border styling per variant matching Bootstrap 1:1.
    #
    # @return [String]
    def variant_classes # rubocop:disable Metrics/MethodLength
      case variant
      when :info # Category tags & active filters (.text-bg-info: #17a2b8 with white text)
        "tw:bg-brand-info tw:text-white tw:border-brand-info"
      when :warning # Characteristic tags (.text-bg-warning: #ffc107 with black text)
        "tw:bg-[#ffc107] tw:text-gray-950 tw:border-[#ffc107]"
      when :success # International event tag & success (.text-bg-success: #28a745 with white text)
        "tw:bg-esperanto-500 tw:text-white tw:border-esperanto-500"
      when :primary # Active city count tags (.text-bg-primary: #2d89ef with white text)
        "tw:bg-brand-blue tw:text-white tw:border-brand-blue"
      when :secondary # Nearby tag & past count tags (.text-bg-secondary: #6c757d with white text)
        "tw:bg-gray-600 tw:text-white tw:border-gray-600"
      when :light # Inactive filter tags (.text-bg-light: #f8f9fa with dark text and subtle border)
        "tw:bg-gray-100 tw:text-gray-800 tw:border-gray-300"
      when :danger # Error / cancelled (.text-bg-danger: #b91d47 with white text)
        "tw:bg-brand-red tw:text-white tw:border-brand-red"
      end
    end

    # Classes applied when rendering an anchor tag.
    #
    # @return [String, nil]
    def interactive_classes
      "tw:cursor-pointer tw:transition-opacity tw:hover:opacity-80" if link?
    end
  end
end
