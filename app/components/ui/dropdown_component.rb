# frozen_string_literal: true

module Ui
  # Renders accessible disclosure menus styled with Tailwind CSS utilities.
  #
  # Supports customizable trigger buttons, vertical menu panels aligned left or right,
  # upward or downward expansion, interactive items with icons, section headers, and
  # visual dividers controlled via the Stimulus menu controller.
  class DropdownComponent < ViewComponent::Base
    ALIGNS = {
      left: :left,
      start: :left,
      right: :right,
      end: :right
    }.freeze

    DIRECTIONS = {
      down: :down,
      up: :up
    }.freeze

    WIDTHS = {
      auto: :auto,
      medium: :medium,
      large: :large
    }.freeze

    # Trigger button slot that toggles the disclosure menu panel.
    class Trigger < ViewComponent::Base
      VARIANTS = {
        default: :default,
        ghost: :ghost,
        light: :light,
        primary: :primary,
        inverse: :inverse
      }.freeze

      attr_reader :label, :icon_name, :icon_style, :caret, :variant, :menu_id, :html_options

      # Creates a trigger button for the disclosure menu.
      #
      # @param label [String, nil] trigger button text (or provide a block)
      # @param icon [String, nil] optional Font Awesome icon name
      # @param icon_style [String] Font Awesome style prefix ("fas", "far", "fab")
      # @param caret [Boolean] whether to show a chevron indicator
      # @param variant [Symbol] visual style (:default, :ghost, :light, :primary, :inverse)
      # @param menu_id [String, nil] ID of the controlled menu panel
      # @param html_options [Hash] additional HTML attributes
      #
      # @return [Ui::DropdownComponent::Trigger]
      def initialize(
        label = nil,
        icon: nil,
        icon_style: "fas",
        caret: true,
        variant: :default,
        menu_id: nil,
        **html_options
      )
        @label = label
        @icon_name = icon&.to_s
        @icon_style = icon_style
        @caret = caret
        @variant = VARIANTS.fetch(variant.to_sym) { :default }
        @menu_id = menu_id
        @html_options = html_options
      end

      # Computes CSS classes for the trigger button.
      #
      # @return [String]
      def trigger_classes
        [
          "tw:inline-flex tw:items-center tw:justify-center tw:gap-1.5 tw:rounded-md",
          "tw:text-sm tw:font-medium tw:transition-colors tw:cursor-pointer",
          "focus:tw:outline-none focus:tw:ring-2 focus:tw:ring-esperanto-500/40",
          variant_classes,
          html_options[:class]
        ].compact.join(" ")
      end

      # Renders the trigger button markup.
      #
      # @return [ActiveSupport::SafeBuffer]
      def call
        content_tag(:button, type: "button", class: trigger_classes, **merged_attributes) do
          if content.present?
            content
          else
            render_default_content
          end
        end
      end

      private

      # Merges Stimulus targets, actions, and ARIA attributes onto the trigger.
      #
      # @return [Hash]
      def merged_attributes
        attrs = html_options.except(:class)
        data = (attrs[:data] || {}).dup
        data[:menu_target] ||= "button"
        data[:action] = ["click->menu#toggle", data[:action]].compact.join(" ")
        attrs[:data] = data

        aria = (attrs[:aria] || {}).dup
        aria[:haspopup] ||= "true"
        aria[:expanded] = "false" unless aria.key?(:expanded)
        aria[:controls] ||= menu_id if menu_id.present?
        attrs[:aria] = aria
        attrs
      end

      # Returns Tailwind classes for the configured trigger variant.
      #
      # @return [String]
      def variant_classes
        case variant
        when :ghost
          "tw:px-2.5 tw:py-1.5 tw:bg-transparent tw:border-0 tw:text-gray-700 hover:tw:bg-gray-100"
        when :light
          "tw:px-3 tw:py-1.5 tw:bg-gray-100 tw:border tw:border-gray-200 tw:text-gray-800 hover:tw:bg-gray-200"
        when :primary
          "tw:px-3.5 tw:py-2 tw:bg-esperanto-500 tw:border tw:border-esperanto-500 tw:text-white hover:tw:bg-esperanto-600"
        when :inverse
          "tw:px-2.5 tw:py-1.5 tw:bg-transparent tw:border-0 tw:text-white/95 hover:tw:bg-white/15 hover:tw:text-white"
        else
          "tw:px-3.5 tw:py-2 tw:bg-white tw:border tw:border-gray-300 tw:text-gray-700 tw:shadow-xs hover:tw:bg-gray-50"
        end
      end

      # Renders leading icon, text label, and trailing chevron.
      #
      # @return [ActiveSupport::SafeBuffer]
      def render_default_content
        safe_join([
          (tag.i(class: "#{icon_style} fa-#{icon_name} tw:text-xs", aria: {hidden: "true"}) if icon_name.present?),
          (content_tag(:span, label) if label.present?),
          (tag.i(class: "fas fa-chevron-down tw:text-[10px] tw:opacity-75", aria: {hidden: "true"}) if caret)
        ].compact)
      end
    end

    # Interactive menu entry rendered inside the panel.
    class Item < ViewComponent::Base
      attr_reader :label, :href, :icon_name, :icon_style, :destructive, :active, :html_options

      # Creates a menu item link or action.
      #
      # @param label [String, nil] item text (or provide a block)
      # @param href [String] destination URL
      # @param icon [String, nil] optional Font Awesome icon name
      # @param icon_style [String] Font Awesome style prefix
      # @param destructive [Boolean] highlights destructive actions in red
      # @param active [Boolean] highlights the currently selected item
      # @param html_options [Hash] additional HTML attributes
      #
      # @return [Ui::DropdownComponent::Item]
      def initialize(
        label = nil,
        href: "#",
        icon: nil,
        icon_style: "fas",
        destructive: false,
        active: false,
        **html_options
      )
        @label = label
        @href = href
        @icon_name = icon&.to_s
        @icon_style = icon_style
        @destructive = destructive
        @active = active
        @html_options = html_options
      end

      # Computes CSS classes for the menu item.
      #
      # @return [String]
      def item_classes
        [
          "tw:flex tw:items-center tw:gap-2.5 tw:w-full tw:px-3.5 tw:py-2 tw:text-sm",
          "tw:no-underline tw:transition-colors tw:text-left",
          "focus:tw:outline-none focus:tw:bg-gray-100",
          state_classes,
          html_options[:class]
        ].compact.join(" ")
      end

      # Renders the menu item link.
      #
      # @return [ActiveSupport::SafeBuffer]
      def call
        content_tag(:a, href: href, class: item_classes, **merged_attributes) do
          if content.present?
            content
          else
            render_default_content
          end
        end
      end

      private

      # Merges role, tabindex, and Stimulus target attributes.
      #
      # @return [Hash]
      def merged_attributes
        attrs = html_options.except(:class)
        attrs[:role] ||= "menuitem"
        attrs[:tabindex] = "-1" unless attrs.key?(:tabindex)
        data = (attrs[:data] || {}).dup
        data[:menu_target] ||= "item"
        attrs[:data] = data
        attrs
      end

      # Returns color classes based on active or destructive state.
      #
      # @return [String]
      def state_classes
        if destructive
          "tw:text-red-700 hover:tw:bg-red-50 hover:tw:text-red-800 focus:tw:bg-red-50"
        elsif active
          "tw:bg-esperanto-50 tw:text-esperanto-700 tw:font-medium hover:tw:bg-esperanto-100"
        else
          "tw:text-gray-700 hover:tw:bg-gray-100 hover:tw:text-gray-900"
        end
      end

      # Renders optional icon and item label.
      #
      # @return [ActiveSupport::SafeBuffer]
      def render_default_content
        safe_join([
          (tag.i(class: "#{icon_style} fa-#{icon_name} tw:w-4 tw:text-center tw:opacity-75", aria: {hidden: "true"}) if icon_name.present?),
          content_tag(:span, label)
        ].compact)
      end
    end

    # Visual separator line between menu item groups.
    class Divider < ViewComponent::Base
      # Renders a horizontal separator with ARIA role.
      #
      # @return [ActiveSupport::SafeBuffer]
      def call
        tag.div(role: "separator", class: "tw:my-1 tw:border-t tw:border-gray-200")
      end
    end

    # Non-interactive section heading inside the menu panel.
    class Header < ViewComponent::Base
      attr_reader :text

      # Creates a section header inside the menu.
      #
      # @param text [String, nil] heading text (or provide a block)
      #
      # @return [Ui::DropdownComponent::Header]
      def initialize(text = nil)
        @text = text
      end

      # Renders the section heading.
      #
      # @return [ActiveSupport::SafeBuffer]
      def call
        content_tag(
          :div,
          content.presence || text,
          role: "presentation",
          class: "tw:px-3.5 tw:py-1.5 tw:text-xs tw:font-semibold tw:uppercase tw:tracking-wider tw:text-gray-500"
        )
      end
    end

    renders_one :trigger, ->(label = nil, icon: nil, icon_style: "fas", caret: true, variant: :default, **html_options) do
      Trigger.new(label, icon:, icon_style:, caret:, variant:, menu_id:, **html_options)
    end

    renders_many :entries, types: {
      item: Item,
      divider: Divider,
      header: Header
    }

    attr_reader :align, :direction, :width, :menu_id, :html_options

    # Adds an interactive item entry to the disclosure menu.
    #
    # @param args [Array] positional arguments forwarded to {Item}
    # @param kwargs [Hash] keyword arguments forwarded to {Item}
    #
    # @return [Ui::DropdownComponent::Item]
    def with_item(*args, **kwargs, &block)
      with_entry_item(*args, **kwargs, &block)
    end

    # Adds a visual separator line to the disclosure menu.
    #
    # @param args [Array] positional arguments forwarded to {Divider}
    # @param kwargs [Hash] keyword arguments forwarded to {Divider}
    #
    # @return [Ui::DropdownComponent::Divider]
    def with_divider(*args, **kwargs, &block)
      with_entry_divider(*args, **kwargs, &block)
    end

    # Adds a section heading to the disclosure menu.
    #
    # @param args [Array] positional arguments forwarded to {Header}
    # @param kwargs [Hash] keyword arguments forwarded to {Header}
    #
    # @return [Ui::DropdownComponent::Header]
    def with_header(*args, **kwargs, &block)
      with_entry_header(*args, **kwargs, &block)
    end

    # Creates a new disclosure menu component instance.
    #
    # @param align [Symbol] horizontal alignment of the panel (:left, :start, :right, :end)
    # @param direction [Symbol] vertical opening direction (:down, :up)
    # @param width [Symbol] panel width (:auto, :medium, :large)
    # @param menu_id [String, nil] optional explicit ID for the menu panel
    # @param html_options [Hash] additional HTML attributes for the wrapper element
    #
    # @return [Ui::DropdownComponent]
    def initialize(
      align: :left,
      direction: :down,
      width: :medium,
      menu_id: nil,
      **html_options
    )
      @align = ALIGNS.fetch(align.to_sym) { :left }
      @direction = DIRECTIONS.fetch(direction.to_sym) { :down }
      @width = WIDTHS.fetch(width.to_sym) { :medium }
      @menu_id = menu_id.presence || "menu-panel-#{object_id}"
      @html_options = html_options
    end

    # Computes CSS classes for the root wrapper element.
    #
    # @return [String]
    def wrapper_classes
      [
        "tw:relative tw:inline-block tw:text-left",
        html_options[:class]
      ].compact.join(" ")
    end

    # Computes attributes for the root wrapper element with Stimulus controller wiring.
    #
    # @return [Hash]
    def wrapper_attributes
      attrs = html_options.except(:class)
      data = (attrs[:data] || {}).dup
      data[:controller] = [data[:controller], "menu"].compact.join(" ")
      attrs[:data] = data
      attrs
    end

    # Computes CSS classes for the floating menu panel.
    #
    # @return [String]
    def panel_classes
      [
        "tw:hidden tw:absolute tw:z-50 tw:py-1 tw:bg-white tw:rounded-lg",
        "tw:shadow-lg tw:border tw:border-gray-200 focus:tw:outline-none",
        position_classes,
        width_classes
      ].join(" ")
    end

    private

    # Returns Tailwind positioning classes for alignment and vertical direction.
    #
    # @return [String]
    def position_classes
      horizontal = (align == :right) ? "tw:right-0 tw:left-auto" : "tw:left-0"
      vertical = (direction == :up) ? "tw:bottom-full tw:mb-1.5" : "tw:top-full tw:mt-1.5"
      "#{horizontal} #{vertical}"
    end

    # Returns Tailwind width classes for the menu panel.
    #
    # @return [String]
    def width_classes
      case width
      when :auto then "tw:min-w-48"
      when :large then "tw:w-64"
      else "tw:w-56"
      end
    end
  end
end
