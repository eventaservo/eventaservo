# frozen_string_literal: true

module Ui
  # Renders accessible WAI-ARIA tab lists and panels styled with Tailwind CSS utilities.
  #
  # Supports optional Font Awesome icons, item count pills, horizontal scrolling on narrow
  # viewports, and roving tabindex keyboard navigation via the Stimulus tabs controller.
  class TabsComponent < ViewComponent::Base
    ACTIVE_TAB_CLASSES = "tw:border-esperanto-500 tw:text-esperanto-600 tw:bg-esperanto-50/60 tw:font-semibold"
    INACTIVE_TAB_CLASSES = "tw:border-transparent tw:text-gray-600 tw:bg-transparent tw:hover:text-esperanto-600 tw:hover:border-esperanto-500/40 tw:hover:bg-gray-50 tw:font-medium"
    BASE_TAB_CLASSES = "tw:inline-flex tw:items-center tw:gap-1.5 tw:px-2.5 tw:py-1.5 tw:text-xs tw:leading-tight tw:border-0 tw:border-b-2 tw:border-solid tw:-mb-px tw:cursor-pointer tw:whitespace-nowrap tw:transition-colors tw:focus-visible:outline-none tw:focus-visible:ring-2 tw:focus-visible:ring-esperanto-500/40 tw:rounded-t-[3px]"
    ACTIVE_COUNT_CLASSES = "tw:bg-esperanto-100 tw:text-esperanto-600 tw:border-esperanto-500/30"
    INACTIVE_COUNT_CLASSES = "tw:bg-gray-100 tw:text-gray-600 tw:border-gray-200"

    # Individual tab definition pairing a tab trigger with its controlled panel content.
    class TabItem < ViewComponent::Base
      attr_reader :tab_id, :label, :icon_name, :icon_style, :count, :active, :html_options

      # Creates a tab item and captures its panel content block.
      #
      # @param id [String, Symbol] unique identifier used for tab and panel element IDs
      # @param label [String] visible tab label
      # @param icon [String, nil] optional Font Awesome icon name
      # @param icon_style [String] Font Awesome style prefix ("fas", "far", "fab")
      # @param count [Integer, String, nil] optional numeric counter pill
      # @param active [Boolean] whether this tab starts selected
      # @param html_options [Hash] additional HTML attributes applied to the tab element
      #
      # @return [Ui::TabsComponent::TabItem]
      def initialize(
        id:,
        label:,
        icon: nil,
        icon_style: "fas",
        count: nil,
        active: false,
        **html_options
      )
        @tab_id = id.to_s
        @label = label
        @icon_name = icon&.to_s
        @icon_style = icon_style
        @count = count
        @active = active
        @html_options = html_options
      end

      # Renders the panel content block captured by the slot.
      #
      # @return [ActiveSupport::SafeBuffer, String, nil]
      def call
        content
      end

      # Returns the DOM ID for the tab trigger element.
      #
      # @return [String]
      def trigger_id
        "#{tab_id}-tab"
      end

      # Returns the DOM ID for the controlled panel element.
      #
      # @return [String]
      def panel_id
        "#{tab_id}-panel"
      end

      # Computes CSS classes for the tab trigger element.
      #
      # @param selected [Boolean] whether this tab is currently selected
      #
      # @return [String]
      def tab_classes(selected:)
        [
          BASE_TAB_CLASSES,
          (selected ? "#{ACTIVE_TAB_CLASSES} active" : INACTIVE_TAB_CLASSES),
          html_options[:class]
        ].compact.join(" ")
      end

      # Computes CSS classes for the panel element.
      #
      # @param selected [Boolean] whether this panel is currently visible
      #
      # @return [String]
      def panel_classes(selected:)
        [
          "tw:pt-3 tw:focus:outline-none",
          (selected ? "show active" : "tw:hidden")
        ].join(" ")
      end

      # Builds HTML attributes for the tab trigger element.
      #
      # @param selected [Boolean] whether this tab starts selected
      #
      # @return [Hash]
      def trigger_attributes(selected:)
        attrs = html_options.except(:class)
        data = (attrs[:data] || {}).dup
        data[:tabs_target] ||= "tab"
        data[:action] = ["click->tabs#select", data[:action]].compact.join(" ")
        data[:tabs_active_class] ||= ACTIVE_TAB_CLASSES
        data[:tabs_inactive_class] ||= INACTIVE_TAB_CLASSES
        attrs[:data] = data

        attrs[:id] = trigger_id
        attrs[:type] = "button"
        attrs[:role] = "tab"
        attrs[:aria] = {
          controls: panel_id,
          selected: selected.to_s
        }
        attrs[:tabindex] = selected ? "0" : "-1"
        attrs
      end

      # Builds HTML attributes for the panel element.
      #
      # @return [Hash]
      def panel_attributes
        {
          id: panel_id,
          role: "tabpanel",
          tabindex: "0",
          aria: {labelledby: trigger_id},
          data: {
            tabs_target: "panel",
            tabs_hidden_class: "tw:hidden"
          }
        }
      end

      # Renders the inner label markup (icon, text, and optional count pill).
      #
      # @param selected [Boolean] whether this tab starts selected
      #
      # @return [ActiveSupport::SafeBuffer]
      def render_label_content(selected: false)
        safe_join([
          (tag.i(class: "#{icon_style} fa-#{icon_name} tw:text-[11px]", aria: {hidden: "true"}) if icon_name.present?),
          content_tag(:span, label, class: "tw:truncate"),
          render_count_pill(selected:)
        ].compact)
      end

      private

      # Renders the counter pill when a count value is provided.
      #
      # @param selected [Boolean] whether this tab starts selected
      #
      # @return [ActiveSupport::SafeBuffer, nil]
      def render_count_pill(selected: false)
        return if count.nil?

        content_tag(
          :span,
          count,
          data: {
            tabs_count: "true",
            tabs_active_class: ACTIVE_COUNT_CLASSES,
            tabs_inactive_class: INACTIVE_COUNT_CLASSES
          },
          class: [
            "tw:inline-flex tw:items-center tw:justify-center tw:rounded-full tw:border tw:border-solid tw:px-1.5 tw:py-0.5 tw:text-[10px] tw:leading-none tw:font-semibold tw:transition-colors",
            (selected ? ACTIVE_COUNT_CLASSES : INACTIVE_COUNT_CLASSES)
          ].join(" ")
        )
      end
    end

    renders_many :tabs, TabItem

    attr_reader :wrapper_id, :aria_label, :html_options

    # Creates a new WAI-ARIA tabs component.
    #
    # @param id [String, nil] optional DOM ID for the root wrapper
    # @param aria_label [String, nil] optional accessible label for the tab list
    # @param html_options [Hash] additional HTML attributes for the root wrapper
    #
    # @return [Ui::TabsComponent]
    def initialize(id: nil, aria_label: nil, **html_options)
      @wrapper_id = id.presence || "tabs-#{object_id}"
      @aria_label = aria_label
      @html_options = html_options
    end

    # Returns the zero-based index of the initially active tab.
    #
    # @return [Integer]
    def active_index
      idx = tabs.index(&:active)
      idx || 0
    end

    # Computes CSS classes for the root wrapper element.
    #
    # @return [String]
    def wrapper_classes
      ["tw:w-full", html_options[:class]].compact.join(" ")
    end

    # Builds attributes for the root wrapper element with Stimulus controller wiring.
    #
    # @return [Hash]
    def wrapper_attributes
      attrs = html_options.except(:class)
      data = (attrs[:data] || {}).dup
      data[:controller] = [data[:controller], "tabs"].compact.join(" ")
      data[:tabs_index_value] ||= active_index
      attrs[:data] = data
      attrs[:id] = wrapper_id
      attrs
    end

    # Returns Tailwind classes for the tab list bar.
    #
    # @return [String]
    def tablist_classes
      "tw:flex tw:flex-nowrap tw:overflow-x-auto tw:border-0 tw:border-b tw:border-solid tw:border-gray-200 tw:gap-0.5"
    end

    # Returns attributes for the tab list wrapper.
    #
    # @return [Hash]
    def tablist_attributes
      attrs = {role: "tablist"}
      attrs[:aria] = {label: aria_label} if aria_label.present?
      attrs
    end
  end
end
