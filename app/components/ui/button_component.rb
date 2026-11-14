# frozen_string_literal: true

module Ui
  # Renders accessible buttons and link buttons styled with Tailwind CSS utilities.
  #
  # Supports standard application actions (submit/save, create/new, cancel,
  # delete, navigation back, outline styles) in multiple sizes with optional
  # Font Awesome icons, accessible disabled states, and full-width layouts.
  class ButtonComponent < ViewComponent::Base
    VARIANTS = {
      primary: :primary,
      success: :success,
      secondary: :secondary,
      outline_primary: :outline_primary,
      outline_danger: :outline_danger,
      danger: :danger,
      cancel: :cancel,
      delete: :delete,
      new_link: :new_link,
      link: :link
    }.freeze

    SIZES = {
      small: :small,
      medium: :medium,
      large: :large,
      # Developer convenience aliases
      xs: :small,
      sm: :medium,
      md: :large,
      lg: :large
    }.freeze

    attr_reader :variant, :size, :href, :type, :icon_name, :icon_style,
      :icon_position, :text, :disabled, :full_width, :html_options

    # Creates a new button component instance.
    #
    # @param text [String, nil] button label text (or pass content block)
    # @param variant [Symbol] style variant (:primary, :success, :secondary,
    #   :outline_primary, :outline_danger, :danger, :cancel, :delete, :new_link, :link)
    # @param size [Symbol] button size (:small, :medium, :large; defaults to :medium)
    # @param href [String, nil] URL target; when present, renders an <a> tag
    # @param type [Symbol, String] button type attribute for <button> (:button, :submit, :reset)
    # @param icon [String, Symbol, nil] Font Awesome icon name (e.g. "arrow-left", "plus")
    # @param icon_style [String] Font Awesome style ("fas", "far", "fab"; defaults to "fas")
    # @param icon_position [Symbol] icon placement relative to text (:leading, :trailing)
    # @param disabled [Boolean] whether the button or link is disabled
    # @param full_width [Boolean] whether the button spans 100% width
    # @param html_options [Hash] additional HTML attributes (classes, data, aria, id)
    #
    # @return [Ui::ButtonComponent]
    def initialize(
      text = nil,
      variant: :primary,
      size: :medium,
      href: nil,
      type: :button,
      icon: nil,
      icon_style: "fas",
      icon_position: :leading,
      disabled: false,
      full_width: false,
      **html_options
    )
      @text = text
      @variant = VARIANTS.fetch(variant.to_sym) { :primary }
      @size = SIZES.fetch(size.to_sym) { :medium }
      @href = href
      @type = type
      @icon_name = icon&.to_s
      @icon_style = icon_style
      @icon_position = icon_position.to_sym
      @disabled = disabled
      @full_width = full_width
      @html_options = html_options
    end

    # Determines whether this component renders an anchor tag instead of a button.
    #
    # @return [Boolean]
    def link?
      href.present?
    end

    # Returns the HTML tag name to render ("a" or "button").
    #
    # @return [String]
    def tag_name
      link? ? "a" : "button"
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

    # Combines base, variant, size, layout, state and caller-provided CSS classes.
    #
    # @return [String]
    def computed_classes
      [
        base_classes,
        size_classes,
        variant_classes,
        width_classes,
        state_classes,
        html_options[:class]
      ].compact.join(" ")
    end

    # Merges all HTML attributes for the rendered element.
    #
    # @return [Hash]
    def element_attributes
      attrs = html_options.except(:class)
      attrs[:class] = computed_classes

      if link?
        attrs[:href] = href unless disabled
        http_method = attrs.delete(:method)
        attrs[:data] = (attrs[:data] || {}).merge(method: http_method) if http_method.present? && !disabled
        if disabled
          attrs[:role] = "link"
          attrs[:aria] = (attrs[:aria] || {}).merge(disabled: "true")
          attrs[:tabindex] = "-1"
        end
      else
        attrs[:type] = type
        attrs[:disabled] = true if disabled
      end

      attrs
    end

    private

    # Common baseline classes for all button variants.
    #
    # @return [String]
    def base_classes
      "tw:inline-flex tw:items-center tw:justify-center tw:gap-1.5 tw:font-normal " \
        "tw:text-center tw:select-none tw:rounded-[3px] tw:transition-colors " \
        "tw:cursor-pointer tw:no-underline tw:border tw:border-solid " \
        "tw:focus-visible:outline-none tw:focus-visible:ring-2 tw:focus-visible:ring-offset-1"
    end

    # Classes defining padding, font size, and line height.
    #
    # @return [String]
    def size_classes
      case size
      when :small
        "tw:text-xs tw:px-1.5 tw:py-0.5 tw:leading-tight"
      when :large
        "tw:text-base tw:px-3 tw:py-1.5 tw:leading-normal"
      else # :medium (standard default)
        "tw:text-sm tw:px-2 tw:py-1 tw:leading-snug"
      end
    end

    # Classes applying colors, borders and background per variant.
    #
    # @return [String]
    def variant_classes # rubocop:disable Metrics/MethodLength
      case variant
      when :primary
        "tw:bg-brand-blue tw:border-brand-blue tw:text-white tw:hover:bg-brand-blue-hover " \
          "tw:hover:border-brand-blue-hover tw:focus-visible:ring-brand-blue/40"
      when :success
        "tw:bg-esperanto-500 tw:border-esperanto-500 tw:text-white tw:hover:bg-esperanto-600 " \
          "tw:hover:border-esperanto-600 tw:focus-visible:ring-esperanto-500/40"
      when :secondary
        "tw:bg-transparent tw:border-gray-500 tw:text-gray-700 tw:hover:bg-gray-500 " \
          "tw:hover:text-white tw:focus-visible:ring-gray-400"
      when :outline_primary
        "tw:bg-transparent tw:border-brand-blue tw:text-brand-blue tw:hover:bg-brand-blue " \
          "tw:hover:text-white tw:focus-visible:ring-brand-blue/40"
      when :outline_danger
        "tw:bg-transparent tw:border-brand-red tw:text-brand-red tw:hover:bg-brand-red " \
          "tw:hover:text-white tw:focus-visible:ring-brand-red/40"
      when :danger
        "tw:bg-brand-red tw:border-brand-red tw:text-white tw:hover:bg-brand-red-hover " \
          "tw:hover:border-brand-red-hover tw:focus-visible:ring-brand-red/40"
      when :cancel
        "tw:bg-transparent tw:border-transparent tw:text-gray-500 tw:hover:text-brand-red " \
          "tw:focus-visible:ring-gray-300"
      when :delete
        "tw:bg-transparent tw:border-transparent tw:text-brand-red tw:hover:text-brand-red-hover " \
          "tw:focus-visible:ring-brand-red/40"
      when :new_link
        "tw:bg-transparent tw:border-transparent tw:text-esperanto-500 tw:hover:text-esperanto-600 " \
          "tw:focus-visible:ring-esperanto-500/40"
      when :link
        "tw:bg-transparent tw:border-transparent tw:text-brand-blue tw:hover:text-brand-blue-hover " \
          "tw:focus-visible:ring-brand-blue/40"
      end
    end

    # Width utilities.
    #
    # @return [String, nil]
    def width_classes
      "tw:w-full" if full_width
    end

    # Interactive state utilities.
    #
    # @return [String]
    def state_classes
      if disabled
        "tw:opacity-65 tw:pointer-events-none tw:cursor-not-allowed"
      else
        "tw:disabled:opacity-65 tw:disabled:pointer-events-none tw:disabled:cursor-not-allowed"
      end
    end
  end
end
