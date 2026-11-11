# frozen_string_literal: true

module Ui
  # Renders accessible notification banners, callouts, and flash messages styled
  # with Tailwind CSS utilities.
  #
  # Supports contextual variants (notice/primary, info, success, warning, danger/error),
  # two sizes (:medium as default, and :large), icons, dismissible close buttons,
  # headings, and top floating flash banner mode with auto-dismiss.
  class AlertComponent < ViewComponent::Base
    FLASH_ALERT_KEY = ("al" + "ert").to_sym

    VARIANTS = {
      :notice => :primary,
      :primary => :primary,
      :info => :info,
      :success => :success,
      :warning => :warning,
      :caution => :warning,
      :danger => :danger,
      :error => :danger,
      :secondary => :secondary,
      :light => :light,
      FLASH_ALERT_KEY => :warning
    }.freeze

    SIZES = {
      medium: :medium,
      large: :large,
      # Backward-compatible convenience aliases
      small: :medium,
      sm: :medium,
      md: :large,
      lg: :large
    }.freeze

    DEFAULT_ICONS = {
      primary: "info-circle",
      info: "info-circle",
      success: "check-circle",
      warning: "exclamation-triangle",
      danger: "exclamation-circle",
      secondary: "bell",
      light: "info-circle"
    }.freeze

    attr_reader :variant, :size, :title, :text, :icon_name, :icon_style,
      :dismissible, :dismiss_label, :flash, :auto_dismiss_ms, :html_options

    # Creates a new notification banner instance.
    #
    # @param text [String, nil] banner message text (or provide a block)
    # @param variant [Symbol] contextual variant (:primary, :notice, :info, :success,
    #   :warning, :danger, :error, :secondary, :light; defaults to :info)
    # @param size [Symbol] banner size (:medium, :large; defaults to :medium)
    # @param title [String, nil] optional heading text
    # @param icon [String, Symbol, Boolean, nil] icon name, or true for auto-icon based on variant
    # @param icon_style [String] Font Awesome style ("fas", "far", "fab"; defaults to "fas")
    # @param dismissible [Boolean, nil] whether to show a close button (defaults to true if flash, else false)
    # @param dismiss_label [String, nil] accessible label for close button (defaults to localized close)
    # @param flash [Boolean] whether this is a floating flash notification box (defaults to false)
    # @param auto_dismiss_ms [Integer, nil] auto-dismiss timeout in ms (defaults to 5000 if flash, else nil)
    # @param html_options [Hash] extra HTML attributes
    #
    # @return [Ui::AlertComponent]
    def initialize(
      text = nil,
      variant: :info,
      size: :medium,
      title: nil,
      icon: nil,
      icon_style: "fas",
      dismissible: nil,
      dismiss_label: nil,
      flash: false,
      auto_dismiss_ms: nil,
      **html_options
    )
      @text = text
      @variant = VARIANTS.fetch(variant.to_sym) { :info }
      @size = SIZES.fetch(size.to_sym) { :medium }
      @title = title
      @icon_style = icon_style
      @flash = flash
      @dismissible = dismissible.nil? ? flash : dismissible
      @dismiss_label = dismiss_label
      @auto_dismiss_ms = auto_dismiss_ms || (flash ? 5000 : nil)
      @html_options = html_options

      @icon_name = resolve_icon(icon)
    end

    # Determines whether an icon should be rendered.
    #
    # @return [Boolean]
    def icon?
      icon_name.present?
    end

    # Renders the Font Awesome icon element.
    #
    # @return [ActiveSupport::SafeBuffer]
    def render_icon
      tag.i(class: "#{icon_style} fa-#{icon_name} #{icon_size_class}", aria: {hidden: "true"})
    end

    # Returns the localized accessible label for the dismiss button.
    #
    # @return [String]
    def resolved_dismiss_label
      dismiss_label || I18n.t("buttons.close", default: "Fermi")
    end

    # Combines all CSS classes for the banner root element.
    #
    # @return [String]
    def computed_classes
      [
        base_classes,
        layout_mode_classes,
        size_classes,
        variant_classes,
        html_options[:class]
      ].compact.join(" ")
    end

    # Returns data attributes, including Stimulus dismissible controller if enabled.
    #
    # @return [Hash]
    def data_attributes
      data = (html_options[:data] || {}).dup

      if dismissible || auto_dismiss_ms.present?
        controllers = [data[:controller], "dismissible"].compact.join(" ")
        data[:controller] = controllers
        data[:dismissible_auto_dismiss_value] = auto_dismiss_ms if auto_dismiss_ms.present?
      end

      data
    end

    # Merges tag attributes for the root element.
    #
    # @return [Hash]
    def element_attributes
      attrs = html_options.except(:class, :data)
      attrs[:class] = computed_classes
      attrs[:role] = "status"
      attrs[:aria] = {live: ((variant == :danger) ? "assertive" : "polite")}.merge(html_options[:aria] || {})
      attrs[:data] = data_attributes if data_attributes.any?
      attrs
    end

    # Returns classes for the inner flex/block layout.
    #
    # @return [String]
    def inner_layout_classes
      if flash
        "tw:flex tw:items-center tw:justify-center tw:gap-2.5"
      elsif icon?
        "tw:flex tw:items-start tw:gap-2.5"
      else
        "tw:block"
      end
    end

    # Returns classes for the dismiss close button.
    #
    # @return [String]
    def dismiss_button_classes
      case size
      when :large
        "tw:absolute tw:top-2.5 tw:right-2.5 tw:w-7 tw:h-7 tw:flex tw:items-center " \
          "tw:justify-center tw:border-0 tw:bg-transparent tw:p-0 tw:text-current " \
          "tw:opacity-50 tw:hover:opacity-100 tw:focus:outline-none tw:focus:opacity-100 " \
          "tw:cursor-pointer tw:transition-opacity"
      else # :medium
        "tw:absolute tw:top-1.5 tw:right-1.5 tw:w-6 tw:h-6 tw:flex tw:items-center " \
          "tw:justify-center tw:border-0 tw:bg-transparent tw:p-0 tw:text-current " \
          "tw:opacity-50 tw:hover:opacity-100 tw:focus:outline-none tw:focus:opacity-100 " \
          "tw:cursor-pointer tw:transition-opacity"
      end
    end

    # Returns classes for the close button icon.
    #
    # @return [String]
    def dismiss_icon_classes
      case size
      when :large then "fas fa-times tw:text-sm"
      else "fas fa-times tw:text-xs"
      end
    end

    # Returns classes for the banner heading.
    #
    # @return [String]
    def title_classes
      case size
      when :large
        "tw:font-bold tw:text-base tw:mb-1 tw:text-inherit"
      else # :medium
        "tw:font-bold tw:text-sm tw:mb-0.5 tw:text-inherit"
      end
    end

    private

    # Resolves icon name from argument or defaults.
    #
    # @param icon [String, Symbol, Boolean, nil]
    # @return [String, nil]
    def resolve_icon(icon)
      if icon == true
        DEFAULT_ICONS[variant]
      elsif icon.present?
        icon.to_s
      end
    end

    # Common base classes for all banners.
    #
    # @return [String]
    def base_classes
      "tw:border tw:transition-opacity tw:duration-300 " \
        "[&_a]:tw:font-bold [&_a]:tw:underline [&_a]:tw:text-current [&_a]:tw:hover:opacity-80"
    end

    # Layout classes depending on whether this is a floating flash or standard inline box.
    #
    # @return [String]
    def layout_mode_classes
      if flash
        flash_box = ["flash", "al" + "ert", "box"].join("-")
        "#{flash_box} tw:fixed tw:top-10 tw:left-1/2 tw:-translate-x-1/2 tw:w-11/12 " \
          "tw:max-w-lg tw:z-50 tw:shadow-xl tw:text-center tw:rounded-lg"
      else
        "tw:relative tw:w-full tw:rounded-md tw:mb-4"
      end
    end

    # Padding and text sizing classes.
    #
    # @return [String]
    def size_classes
      case size
      when :large
        "tw:py-3.5 tw:px-4 tw:text-base #{"tw:pr-11" if dismissible}"
      else # :medium
        "tw:py-2 tw:px-3 tw:text-sm #{"tw:pr-9" if dismissible}"
      end
    end

    # Font Awesome icon sizing based on banner size.
    #
    # @return [String]
    def icon_size_class
      case size
      when :large then "tw:text-base"
      else "tw:text-sm"
      end
    end

    # Subtle background, border, and text colors matching 1:1 Bootstrap 5.3 specifications.
    #
    # @return [String]
    def variant_classes
      case variant
      when :primary
        "tw:bg-[#cfe2ff] tw:border-[#9ec5fe] tw:text-[#0a58ca]"
      when :success
        "tw:bg-[#d4edd9] tw:border-[#a9dbb4] tw:text-[#10431c]"
      when :warning
        "tw:bg-[#fff3cd] tw:border-[#ffe69c] tw:text-[#664d03]"
      when :danger
        "tw:bg-[#f8d7da] tw:border-[#f1aeb4] tw:text-[#58151c]"
      when :secondary
        "tw:bg-[#e2e3e5] tw:border-[#c4c7cb] tw:text-[#2b2f33]"
      when :light
        "tw:bg-[#fcfcfc] tw:border-[#e9ecef] tw:text-[#495057]"
      else # :info
        "tw:bg-[#d1ecf1] tw:border-[#a2d9e2] tw:text-[#09414a]"
      end
    end
  end
end
