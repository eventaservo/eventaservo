# frozen_string_literal: true

module Ui
  # Renders accessible text input fields styled with Tailwind CSS utilities.
  #
  # Supports input types (text, email, password, number, date, search, url, tel),
  # sizes (:small, and :medium as default), label, hint, error validation message,
  # leading and trailing icons, and disabled/readonly states.
  class InputComponent < ViewComponent::Base
    SIZES = {
      small: :small,
      medium: :medium,
      sm: :small,
      md: :medium
    }.freeze

    attr_reader :name, :value, :type, :id, :label, :hint, :error,
      :size, :placeholder, :icon_name, :icon_style, :icon_position,
      :disabled, :readonly, :required, :html_options

    # Creates a new input field instance.
    #
    # @param name [String, Symbol, nil] field name attribute
    # @param value [Object, nil] field value
    # @param type [String, Symbol] input type (:text, :email, :password, :number, :date, :search, :url, :tel)
    # @param id [String, nil] custom DOM id (defaults to generated from name)
    # @param label [String, nil] label text
    # @param hint [String, nil] helper text displayed below the field
    # @param error [String, nil] validation error message displayed below the field
    # @param size [Symbol] field size (:small, :medium; defaults to :medium)
    # @param placeholder [String, nil] placeholder text
    # @param icon [String, Symbol, nil] Font Awesome icon name
    # @param icon_style [String] Font Awesome icon style ("fas", "far", "fab"; defaults to "fas")
    # @param icon_position [Symbol] icon position (:leading, :trailing; defaults to :leading)
    # @param disabled [Boolean] whether the field is disabled
    # @param readonly [Boolean] whether the field is readonly
    # @param required [Boolean] whether the field is required
    # @param html_options [Hash] extra HTML attributes for the input tag
    #
    # @return [Ui::InputComponent]
    def initialize(
      name = nil,
      value: nil,
      type: :text,
      id: nil,
      label: nil,
      hint: nil,
      error: nil,
      size: :medium,
      placeholder: nil,
      icon: nil,
      icon_style: "fas",
      icon_position: :leading,
      disabled: false,
      readonly: false,
      required: false,
      **html_options
    )
      @name = name
      @value = value
      @type = type.to_sym
      @id = id
      @label = label
      @hint = hint
      @error = error
      @size = SIZES.fetch(size.to_sym) { :medium }
      @placeholder = placeholder
      @icon_name = icon&.to_s
      @icon_style = icon_style
      @icon_position = icon_position.to_sym
      @disabled = disabled
      @readonly = readonly
      @required = required
      @html_options = html_options
    end

    # Returns the input element ID.
    #
    # @return [String]
    def input_id
      @id.presence || (name.present? ? "input_#{name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}" : "input_#{object_id}")
    end

    # Returns the hint element ID for accessibility.
    #
    # @return [String]
    def hint_id
      "#{input_id}_hint"
    end

    # Returns the error element ID for accessibility.
    #
    # @return [String]
    def error_id
      "#{input_id}_error"
    end

    # Determines whether a label is present.
    #
    # @return [Boolean]
    def label?
      label.present?
    end

    # Determines whether a helper hint is present.
    #
    # @return [Boolean]
    def hint?
      hint.present?
    end

    # Determines whether an error message is present.
    #
    # @return [Boolean]
    def error?
      error.present?
    end

    # Determines whether an icon should be rendered.
    #
    # @return [Boolean]
    def icon?
      icon_name.present?
    end

    # Determines whether the icon precedes the input.
    #
    # @return [Boolean]
    def leading_icon?
      icon? && icon_position != :trailing
    end

    # Determines whether the icon follows the input.
    #
    # @return [Boolean]
    def trailing_icon?
      icon? && icon_position == :trailing
    end

    # Renders the Font Awesome icon element.
    #
    # @return [ActiveSupport::SafeBuffer]
    def render_icon
      tag.i(class: "#{icon_style} fa-#{icon_name} #{icon_size_classes}", aria: {hidden: "true"})
    end

    # Classes for the outer field wrapper.
    #
    # @return [String]
    def wrapper_classes
      "tw:w-full tw:flex tw:flex-col"
    end

    # Classes for the field label.
    #
    # @return [String]
    def label_classes
      case size
      when :small
        "tw:block tw:text-[11px] tw:font-semibold tw:text-gray-600 tw:mb-0.5"
      else # :medium
        "tw:block tw:text-xs tw:font-semibold tw:text-gray-700 tw:mb-1"
      end
    end

    # Classes for the leading icon wrapper.
    #
    # @return [String]
    def leading_icon_wrapper_classes
      pad = ((size == :small) ? "tw:pl-2.5" : "tw:pl-3")
      "tw:absolute tw:inset-y-0 tw:left-0 #{pad} tw:flex tw:items-center tw:pointer-events-none tw:text-gray-400"
    end

    # Classes for the trailing icon wrapper.
    #
    # @return [String]
    def trailing_icon_wrapper_classes
      pad = ((size == :small) ? "tw:pr-2.5" : "tw:pr-3")
      "tw:absolute tw:inset-y-0 tw:right-0 #{pad} tw:flex tw:items-center tw:pointer-events-none tw:text-gray-400"
    end

    # Classes for the input element.
    #
    # @return [String]
    def input_classes
      [
        base_input_classes,
        size_classes,
        icon_padding_classes,
        state_classes,
        html_options[:class]
      ].compact.join(" ")
    end

    # Attributes to forward to the input tag.
    #
    # @return [Hash]
    def input_tag_attributes
      attrs = html_options.except(:class)
      attrs[:type] = type
      attrs[:name] = name if name.present?
      attrs[:id] = input_id
      attrs[:value] = value if value.present?
      attrs[:placeholder] = placeholder if placeholder.present?
      attrs[:disabled] = true if disabled
      attrs[:readonly] = true if readonly
      attrs[:required] = true if required
      attrs[:class] = input_classes

      if error?
        attrs[:"aria-invalid"] = "true"
        attrs[:"aria-describedby"] = error_id
      elsif hint?
        attrs[:"aria-describedby"] = hint_id
      end

      attrs
    end

    private

    # Base classes for input elements.
    #
    # @return [String]
    def base_input_classes
      "tw:block tw:w-full tw:rounded tw:border tw:transition-colors tw:duration-150 " \
        "tw:bg-white tw:text-gray-900 tw:placeholder:text-gray-400"
    end

    # Sizing classes for small and medium.
    #
    # @return [String]
    def size_classes
      case size
      when :small
        "tw:py-1 tw:px-2.5 tw:text-xs"
      else # :medium
        "tw:py-1.5 tw:px-3 tw:text-sm"
      end
    end

    # Padding adjustment when icons are present.
    #
    # @return [String]
    def icon_padding_classes
      classes = []
      if leading_icon?
        classes << ((size == :small) ? "tw:pl-7" : "tw:pl-9")
      end
      if trailing_icon?
        classes << ((size == :small) ? "tw:pr-7" : "tw:pr-9")
      end
      classes.join(" ")
    end

    # Icon size classes.
    #
    # @return [String]
    def icon_size_classes
      (size == :small) ? "tw:text-xs" : "tw:text-sm"
    end

    # State classes: normal, disabled, readonly, error.
    #
    # @return [String]
    def state_classes
      if disabled
        "tw:border-gray-200 tw:bg-gray-100 tw:text-gray-500 tw:cursor-not-allowed"
      elsif readonly
        "tw:border-gray-300 tw:bg-gray-50 tw:text-gray-700 tw:cursor-default"
      elsif error?
        "tw:border-red-500 tw:text-red-950 tw:focus:outline-none tw:focus:border-red-500 " \
          "tw:focus:ring-2 tw:focus:ring-red-500/20"
      else
        "tw:border-gray-300 tw:hover:border-gray-400 tw:focus:outline-none " \
          "tw:focus:border-[#2d89ef] tw:focus:ring-2 tw:focus:ring-[#2d89ef]/20"
      end
    end
  end
end
