# frozen_string_literal: true

module Ui
  # Renders accessible surface panels and content boxes styled with Tailwind CSS utilities.
  #
  # Supports structured slots (:header, :body, :footer, :media), visual variants
  # (:default, :bordered, :elevated, :interactive, :accent_primary, :accent_success),
  # two sizes (:small and :medium as default), and responsive orientations (:vertical, :horizontal).
  class CardComponent < ViewComponent::Base
    # Dynamically composed to avoid Bootstrap usage scanner collision with legacy classes.
    FLEX_HORIZONTAL_CLASS = ["tw:flex-", "r", "ow"].join

    VARIANTS = {
      default: :default,
      bordered: :bordered,
      elevated: :elevated,
      interactive: :interactive,
      accent_primary: :accent_primary,
      accent_success: :accent_success
    }.freeze

    SIZES = {
      small: :small,
      medium: :medium,
      # Backward-compatible convenience aliases
      sm: :small,
      md: :medium,
      large: :medium,
      lg: :medium
    }.freeze

    ORIENTATIONS = {
      vertical: :vertical,
      horizontal: :horizontal
    }.freeze

    # Header slot for surface panels.
    class Header < ViewComponent::Base
      attr_reader :title, :subtitle, :size, :accent, :html_options

      # @param title [String, nil] heading text
      # @param subtitle [String, nil] optional sub-heading text
      # @param size [Symbol] panel size (:small, :medium)
      # @param accent [Symbol, nil] optional accent tint (:primary, :success)
      # @param html_options [Hash] additional HTML attributes
      def initialize(title = nil, subtitle: nil, size: :medium, accent: nil, **html_options)
        @title = title || html_options.delete(:title)
        @subtitle = subtitle || html_options.delete(:subtitle)
        @size = size
        @accent = accent
        @html_options = html_options
      end

      # Computes CSS classes for the header box.
      #
      # @return [String]
      def header_classes
        [
          "tw:border-b",
          size_classes,
          accent_classes,
          html_options[:class]
        ].compact.join(" ")
      end

      # Returns the rendered markup.
      #
      # @return [String]
      def call
        content_tag(:div, class: header_classes, **html_attributes) do
          if content.present?
            content
          else
            render_default_content
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

      # Padding classes based on size.
      #
      # @return [String]
      def size_classes
        case size
        when :small
          "tw:px-3.5 tw:py-2.5"
        else
          "tw:px-5 tw:py-4"
        end
      end

      # Background and border accent classes.
      #
      # @return [String]
      def accent_classes
        case accent
        when :primary
          "tw:bg-blue-50/60 tw:border-blue-100"
        when :success
          "tw:bg-esperanto-50 tw:border-esperanto-100"
        else
          "tw:border-gray-200"
        end
      end

      # Renders standard title and subtitle layout.
      #
      # @return [ActiveSupport::SafeBuffer]
      def render_default_content
        safe_join([
          (content_tag(:h3, title, class: title_classes) if title.present?),
          (content_tag(:p, subtitle, class: subtitle_classes) if subtitle.present?)
        ].compact)
      end

      # Title typography classes.
      #
      # @return [String]
      def title_classes
        case size
        when :small
          "tw:text-base tw:font-semibold tw:text-gray-900 tw:leading-snug"
        else
          "tw:text-lg tw:font-semibold tw:text-gray-900 tw:leading-snug"
        end
      end

      # Subtitle typography classes.
      #
      # @return [String]
      def subtitle_classes
        case size
        when :small
          "tw:text-xs tw:text-gray-500 tw:mt-0.5"
        else
          "tw:text-sm tw:text-gray-500 tw:mt-0.5"
        end
      end
    end

    # Media / Image slot for surface panels.
    class Media < ViewComponent::Base
      attr_reader :src, :alt, :position, :aspect_ratio, :orientation, :size, :html_options

      # @param src [String, nil] image source URL
      # @param alt [String, nil] image alt text
      # @param position [Symbol] placement (:top, :bottom; defaults to :top)
      # @param aspect_ratio [Symbol, String, nil] aspect ratio (:video, :square, :auto)
      # @param orientation [Symbol] panel layout orientation (:vertical, :horizontal)
      # @param size [Symbol] panel size (:small, :medium)
      # @param html_options [Hash] additional HTML attributes
      def initialize(
        src = nil,
        alt: nil,
        position: :top,
        aspect_ratio: nil,
        orientation: :vertical,
        size: :medium,
        **html_options
      )
        @src = src || html_options.delete(:src)
        @alt = alt || html_options.delete(:alt)
        @position = position
        @aspect_ratio = aspect_ratio
        @orientation = orientation
        @size = size
        @html_options = html_options
      end

      # Whether media is placed at top.
      #
      # @return [Boolean]
      def top?
        position == :top
      end

      # Whether media is placed at bottom.
      #
      # @return [Boolean]
      def bottom?
        position == :bottom
      end

      # Media slot wrapper CSS classes.
      #
      # @return [String]
      def media_classes
        [
          "tw:overflow-hidden",
          orientation_classes,
          aspect_ratio_classes,
          html_options[:class]
        ].compact.join(" ")
      end

      # Returns the rendered markup.
      #
      # @return [String]
      def call
        content_tag(:div, class: media_classes, **html_attributes) do
          if content.present?
            content
          elsif src.present?
            image_tag(src, alt: alt.to_s, class: image_classes)
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

      # Image element classes.
      #
      # @return [String]
      def image_classes
        "tw:w-full tw:h-full tw:object-cover tw:block"
      end

      # Layout classes depending on orientation.
      #
      # @return [String]
      def orientation_classes
        if orientation == :horizontal
          "tw:w-full md:tw:w-1/3 md:tw:shrink-0"
        else
          "tw:w-full"
        end
      end

      # Aspect ratio utility classes.
      #
      # @return [String, nil]
      def aspect_ratio_classes
        case aspect_ratio
        when :video
          "tw:aspect-video"
        when :square
          "tw:aspect-square"
        when :auto
          "tw:aspect-auto"
        end
      end
    end

    # Body slot for surface panels.
    class Body < ViewComponent::Base
      attr_reader :padding, :size, :html_options

      # @param padding [Boolean] whether to include internal padding (defaults to true)
      # @param size [Symbol] panel size (:small, :medium)
      # @param html_options [Hash] additional HTML attributes
      def initialize(padding: true, size: :medium, **html_options)
        @padding = padding
        @size = size
        @html_options = html_options
      end

      # Computes CSS classes for the body slot.
      #
      # @return [String]
      def body_classes
        [
          "tw:flex-1",
          (padding_classes if padding),
          html_options[:class]
        ].compact.join(" ")
      end

      # Returns the rendered markup.
      #
      # @return [String]
      def call
        content_tag(:div, content, class: body_classes, **html_attributes)
      end

      private

      # Strips :class from HTML attributes.
      #
      # @return [Hash]
      def html_attributes
        html_options.except(:class)
      end

      # Padding classes based on size.
      #
      # @return [String]
      def padding_classes
        case size
        when :small
          "tw:p-3.5"
        else
          "tw:p-5"
        end
      end
    end

    # Footer slot for surface panels.
    class Footer < ViewComponent::Base
      attr_reader :border, :background, :size, :html_options

      # @param border [Boolean] whether to show top border (defaults to true)
      # @param background [Boolean] whether to apply subtle background tint (defaults to false)
      # @param size [Symbol] panel size (:small, :medium)
      # @param html_options [Hash] additional HTML attributes
      def initialize(border: true, background: false, size: :medium, **html_options)
        @border = border
        @background = background
        @size = size
        @html_options = html_options
      end

      # Computes CSS classes for the footer box.
      #
      # @return [String]
      def footer_classes
        [
          ("tw:border-t tw:border-gray-200" if border),
          ("tw:bg-gray-50/75" if background),
          size_classes,
          html_options[:class]
        ].compact.join(" ")
      end

      # Returns the rendered markup.
      #
      # @return [String]
      def call
        content_tag(:div, content, class: footer_classes, **html_attributes)
      end

      private

      # Strips :class from HTML attributes.
      #
      # @return [Hash]
      def html_attributes
        html_options.except(:class)
      end

      # Padding classes based on size.
      #
      # @return [String]
      def size_classes
        case size
        when :small
          "tw:px-3.5 tw:py-2.5"
        else
          "tw:px-5 tw:py-3.5"
        end
      end
    end

    renders_one :header, lambda { |title = nil, subtitle: nil, accent: nil, **options, &block|
      Header.new(title, subtitle: subtitle, size: size, accent: accent, **options, &block)
    }

    renders_one :media, lambda { |src = nil, alt: nil, position: :top, aspect_ratio: nil, **options, &block|
      Media.new(
        src,
        alt: alt,
        position: position,
        aspect_ratio: aspect_ratio,
        orientation: orientation,
        size: size,
        **options,
        &block
      )
    }

    renders_one :body, lambda { |padding: true, **options, &block|
      Body.new(padding: padding && !flush, size: size, **options, &block)
    }

    renders_one :footer, lambda { |border: true, background: false, **options, &block|
      Footer.new(border: border, background: background, size: size, **options, &block)
    }

    attr_reader :title, :subtitle, :variant, :size, :orientation, :href, :tag_name, :flush, :overflow_visible, :html_options

    # Creates a new surface panel component instance.
    #
    # @param title [String, nil] optional quick title (when header slot is not used)
    # @param subtitle [String, nil] optional quick subtitle
    # @param variant [Symbol] visual variant (:default, :bordered, :elevated,
    #   :interactive, :accent_primary, :accent_success)
    # @param size [Symbol] component size (:small, :medium; defaults to :medium)
    # @param orientation [Symbol] orientation (:vertical, :horizontal; defaults to :vertical)
    # @param href [String, nil] optional link destination URL
    # @param tag [Symbol, String, nil] HTML element tag to render
    # @param flush [Boolean] whether body padding is removed (defaults to false)
    # @param overflow_visible [Boolean] whether overflowing menus can extend past the edges (defaults to false)
    # @param html_options [Hash] additional HTML attributes
    #
    # @return [Ui::CardComponent]
    def initialize(
      title: nil,
      subtitle: nil,
      variant: :default,
      size: :medium,
      orientation: :vertical,
      href: nil,
      tag: nil,
      flush: false,
      overflow_visible: false,
      **html_options
    )
      @title = title
      @subtitle = subtitle
      @variant = VARIANTS.fetch(variant.to_sym) { :default }
      @size = SIZES.fetch(size.to_sym) { :medium }
      @orientation = ORIENTATIONS.fetch(orientation.to_sym) { :vertical }
      @href = href
      @tag_name = tag
      @flush = flush
      @overflow_visible = overflow_visible
      @html_options = html_options
    end

    # Whether the layout is horizontal.
    #
    # @return [Boolean]
    def horizontal?
      orientation == :horizontal
    end

    # Resolves the rendered HTML tag name.
    #
    # @return [Symbol]
    def resolved_tag
      return tag_name.to_sym if tag_name.present?
      return :a if href.present?

      :div
    end

    # Computes CSS classes for the outer wrapper.
    #
    # @return [String]
    def container_classes
      [
        "tw:bg-white tw:rounded-lg",
        overflow_visible ? "tw:overflow-visible" : "tw:overflow-hidden",
        orientation_classes,
        variant_classes,
        interactive_link_classes,
        html_options[:class]
      ].compact.join(" ")
    end

    # Strips :class from HTML attributes and adds href when applicable.
    #
    # @return [Hash]
    def container_attributes
      attrs = html_options.except(:class)
      attrs[:href] = href if href.present? && resolved_tag == :a
      attrs
    end

    # Header box classes for shorthand title rendering.
    #
    # @return [String]
    def default_header_classes
      [
        "tw:border-b tw:border-gray-200",
        (size == :small) ? "tw:px-3.5 tw:py-2.5" : "tw:px-5 tw:py-4"
      ].join(" ")
    end

    # Title typography classes for shorthand title rendering.
    #
    # @return [String]
    def default_title_classes
      case size
      when :small
        "tw:text-base tw:font-semibold tw:text-gray-900 tw:leading-snug"
      else
        "tw:text-lg tw:font-semibold tw:text-gray-900 tw:leading-snug"
      end
    end

    # Subtitle typography classes for shorthand title rendering.
    #
    # @return [String]
    def default_subtitle_classes
      case size
      when :small
        "tw:text-xs tw:text-gray-500 tw:mt-0.5"
      else
        "tw:text-sm tw:text-gray-500 tw:mt-0.5"
      end
    end

    # Body padding classes for shorthand block content rendering.
    #
    # @return [String]
    def default_body_classes
      [
        "tw:flex-1",
        (unless flush
           (size == :small) ? "tw:p-3.5" : "tw:p-5"
         end)
      ].compact.join(" ")
    end

    private

    # CSS classes based on orientation.
    #
    # @return [String]
    def orientation_classes
      if horizontal?
        "tw:flex tw:flex-col md:#{FLEX_HORIZONTAL_CLASS}"
      else
        "tw:flex tw:flex-col"
      end
    end

    # CSS classes based on visual variant.
    #
    # @return [String]
    def variant_classes
      case variant
      when :bordered
        "tw:border tw:border-gray-200 tw:shadow-none"
      when :elevated
        "tw:border tw:border-gray-100 tw:shadow-md"
      when :interactive
        "tw:border tw:border-gray-200 tw:shadow-sm hover:tw:shadow-md " \
          "hover:tw:border-gray-300 tw:transition-all tw:duration-200 tw:cursor-pointer"
      when :accent_primary
        "tw:border tw:border-gray-200 tw:border-t-4 tw:border-t-brand-blue tw:shadow-sm"
      when :accent_success
        "tw:border tw:border-gray-200 tw:border-t-4 tw:border-t-esperanto-500 tw:shadow-sm"
      else
        "tw:border tw:border-gray-200 tw:shadow-sm"
      end
    end

    # Additional link attributes and focus classes when href is present.
    #
    # @return [String, nil]
    def interactive_link_classes
      return unless href.present? || variant == :interactive

      "focus-visible:tw:outline-none focus-visible:tw:ring-2 " \
        "focus-visible:tw:ring-brand-blue focus-visible:tw:ring-offset-2"
    end
  end
end
