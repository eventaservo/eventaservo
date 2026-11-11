# frozen_string_literal: true

module Ui
  # Renders accessible application top navigation bars styled with Tailwind CSS utilities.
  #
  # Supports structured slots (:brand, :search, :items, :tools, :user_menu),
  # mobile responsive layout, and Esperanto green branding.
  class NavbarComponent < ViewComponent::Base
    # Brand link or logo inside the top navigation bar.
    class Brand < ViewComponent::Base
      attr_reader :title, :href, :env_badge, :html_options

      # @param title [String, nil] application or brand name
      # @param href [String] link destination (defaults to "/")
      # @param env_badge [String, nil] optional environment tag (e.g. "DEV", "STAGING")
      # @param html_options [Hash] additional HTML attributes
      def initialize(title = "Eventa Servo", href: "/", env_badge: nil, **html_options)
        @title = title
        @href = href
        @env_badge = env_badge
        @html_options = html_options
      end

      # Returns CSS classes for the brand link.
      #
      # @return [String]
      def brand_classes
        [
          "tw:flex tw:items-center tw:gap-2 tw:font-bold tw:text-lg tw:text-white",
          "tw:tracking-tight tw:no-underline hover:tw:opacity-90 tw:shrink-0",
          html_options[:class]
        ].compact.join(" ")
      end

      # Renders the brand markup.
      #
      # @return [String]
      def call
        content_tag(:a, href: href, class: brand_classes, **html_attributes) do
          if content.present?
            content
          else
            render_default_brand
          end
        end
      end

      private

      # Strips :class from HTML attributes.
      #
      # @return [Hash]
      def html_attributes
        html_options.except(:class)
      end

      # Renders standard title and optional environment tag.
      #
      # @return [ActiveSupport::SafeBuffer]
      def render_default_brand
        safe_join([
          content_tag(:span, title),
          (render_env_tag if env_badge.present?)
        ].compact)
      end

      # Renders environment indicator pill.
      #
      # @return [ActiveSupport::SafeBuffer]
      def render_env_tag
        content_tag(
          :span,
          env_badge,
          class: "tw:text-xs tw:font-semibold tw:bg-black/25 tw:text-white " \
                 "tw:px-1.5 tw:py-0.5 tw:rounded"
        )
      end
    end

    # Integrated search input inside the top navigation bar.
    class Search < ViewComponent::Base
      attr_reader :url, :placeholder, :aria_label, :html_options

      # @param url [String] form submit or controller target URL
      # @param placeholder [String] search field placeholder
      # @param aria_label [String] accessible label
      # @param html_options [Hash] additional HTML attributes
      def initialize(
        url: "/serchilo",
        placeholder: "Serĉi...",
        aria_label: "Serĉi eventojn",
        **html_options
      )
        @url = url
        @placeholder = placeholder
        @aria_label = aria_label
        @html_options = html_options
      end

      # Renders the search input form.
      #
      # @return [String]
      def call
        content_tag(:form, class: form_classes, **form_attributes) do
          content_tag(:div, class: "tw:relative tw:w-full") do
            safe_join([
              render_icon,
              render_input
            ])
          end
        end
      end

      private

      # Form wrapper classes.
      #
      # @return [String]
      def form_classes
        [
          "tw:flex tw:items-center tw:w-full tw:max-w-xs",
          html_options[:class]
        ].compact.join(" ")
      end

      # Form attributes with search controller binding.
      #
      # @return [Hash]
      def form_attributes
        attrs = html_options.except(:class)
        attrs[:data] ||= {}
        attrs[:data][:controller] ||= "search"
        attrs[:data][:search_url_value] ||= url
        attrs
      end

      # Leading search icon.
      #
      # @return [ActiveSupport::SafeBuffer]
      def render_icon
        content_tag(
          :div,
          class: "tw:absolute tw:inset-y-0 tw:left-0 tw:pl-2.5 tw:flex " \
                 "tw:items-center tw:pointer-events-none tw:text-white/70"
        ) do
          content_tag(:i, "", class: "fas fa-search tw:text-xs", aria: {hidden: true})
        end
      end

      # Search input element.
      #
      # @return [ActiveSupport::SafeBuffer]
      def render_input
        tag.input(
          type: "search",
          placeholder: placeholder,
          aria: {label: aria_label},
          class: "tw:w-full tw:pl-8 tw:pr-3 tw:py-1 tw:text-xs tw:rounded-md " \
                 "tw:bg-white/20 tw:text-white tw:placeholder-white/70 " \
                 "tw:border tw:border-white/25 focus:tw:outline-none " \
                 "focus:tw:bg-white focus:tw:text-gray-900 " \
                 "focus:tw:placeholder-gray-400 focus:tw:border-white",
          data: {
            search_target: "searchTerm",
            action: "keyup->search#goToSearchPage"
          }
        )
      end
    end

    # Navigation link item.
    class Item < ViewComponent::Base
      attr_reader :text, :href, :icon_name, :icon_style, :active, :tag_text, :html_options

      # @param text [String, nil] label text
      # @param href [String] destination URL
      # @param icon [String, nil] Font Awesome icon name
      # @param icon_style [String] Font Awesome prefix (defaults to "fas")
      # @param active [Boolean] whether this link is currently active
      # @param tag [String, nil] optional counter or pill text
      # @param html_options [Hash] additional HTML attributes
      def initialize(
        text = nil,
        href: "#",
        icon: nil,
        icon_style: "fas",
        active: false,
        tag: nil,
        **html_options
      )
        @text = text
        @href = href
        @icon_name = icon
        @icon_style = icon_style
        @active = active
        @tag_text = tag
        @html_options = html_options
      end

      # CSS classes for the link.
      #
      # @return [String]
      def item_classes
        [
          "tw:inline-flex tw:items-center tw:gap-1.5 tw:px-3 tw:py-1.5 tw:rounded-md",
          "tw:text-xs tw:font-medium tw:no-underline tw:transition-colors",
          active_classes,
          html_options[:class]
        ].compact.join(" ")
      end

      # Renders the navigation item.
      #
      # @return [String]
      def call
        content_tag(:a, href: href, class: item_classes, **html_attributes) do
          if content.present?
            content
          else
            render_default_item
          end
        end
      end

      private

      # Strips :class from HTML attributes.
      #
      # @return [Hash]
      def html_attributes
        attrs = html_options.except(:class)
        attrs[:aria] ||= {}
        attrs[:aria][:current] = "page" if active
        attrs
      end

      # Active or inactive background classes.
      #
      # @return [String]
      def active_classes
        if active
          "tw:bg-esperanto-700 tw:text-white"
        else
          "tw:text-white/90 hover:tw:bg-white/15 hover:tw:text-white"
        end
      end

      # Standard item content with icon and label.
      #
      # @return [ActiveSupport::SafeBuffer]
      def render_default_item
        safe_join([
          (render_icon if icon_name.present?),
          content_tag(:span, text),
          (render_tag if tag_text.present?)
        ].compact)
      end

      # Icon element.
      #
      # @return [ActiveSupport::SafeBuffer]
      def render_icon
        content_tag(:i, "", class: "#{icon_style} fa-#{icon_name}", aria: {hidden: true})
      end

      # Tag / counter pill.
      #
      # @return [ActiveSupport::SafeBuffer]
      def render_tag
        content_tag(
          :span,
          tag_text,
          class: "tw:ml-1 tw:px-1.5 tw:py-0.2 tw:text-[10px] tw:font-semibold " \
                 "tw:bg-white/20 tw:rounded-full"
        )
      end
    end

    # Tool button or link (e.g. Map toggle, Telegram, About).
    class Tool < ViewComponent::Base
      attr_reader :icon_name, :href, :label, :active, :target, :html_options

      # @param icon [String] Font Awesome icon name
      # @param href [String] destination URL
      # @param label [String] title / aria label
      # @param active [Boolean] whether currently highlighted
      # @param target [String, nil] optional window target (e.g. "_blank")
      # @param html_options [Hash] additional HTML attributes
      def initialize(
        icon:,
        href: "#",
        label: "",
        active: false,
        target: nil,
        **html_options
      )
        @icon_name = icon
        @href = href
        @label = label
        @active = active
        @target = target
        @html_options = html_options
      end

      # CSS classes for the tool button.
      #
      # @return [String]
      def tool_classes
        [
          "tw:inline-flex tw:items-center tw:justify-center tw:w-8 tw:h-8 tw:rounded-md",
          "tw:text-xs tw:no-underline tw:transition-colors",
          highlight_classes,
          html_options[:class]
        ].compact.join(" ")
      end

      # Renders the tool link.
      #
      # @return [String]
      def call
        content_tag(:a, href: href, class: tool_classes, **html_attributes) do
          content_tag(:i, "", class: "fas fa-#{icon_name}", aria: {hidden: true})
        end
      end

      private

      # Strips :class and builds HTML attributes.
      #
      # @return [Hash]
      def html_attributes
        attrs = html_options.except(:class)
        attrs[:title] = label if label.present?
        attrs[:aria] ||= {}
        attrs[:aria][:label] = label if label.present?
        attrs[:target] = target if target.present?
        attrs[:rel] = "noopener noreferrer" if target == "_blank"
        attrs
      end

      # Highlight classes.
      #
      # @return [String]
      def highlight_classes
        if active
          "tw:bg-yellow-400 tw:text-gray-900 shadow-xs"
        else
          "tw:text-white/85 hover:tw:bg-white/15 hover:tw:text-white"
        end
      end
    end

    renders_one :brand, Brand
    renders_one :search, Search
    renders_many :items, Item
    renders_many :tools, Tool
    renders_one :action
    renders_one :user_menu

    attr_reader :html_options

    # Creates a new application top navigation bar component instance.
    #
    # @param html_options [Hash] additional HTML attributes
    #
    # @return [Ui::NavbarComponent]
    def initialize(**html_options)
      @html_options = html_options
    end

    # Outer bar CSS classes.
    #
    # @return [String]
    def bar_classes
      [
        "tw:bg-esperanto-500 tw:text-white tw:shadow-sm",
        html_options[:class]
      ].compact.join(" ")
    end

    # Strips :class from HTML attributes.
    #
    # @return [Hash]
    def bar_attributes
      html_options.except(:class)
    end
  end
end
