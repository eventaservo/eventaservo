# frozen_string_literal: true

module Ui
  # Renders accessible multi-line text input fields styled with Tailwind CSS utilities.
  #
  # Supports rows control, sizes (:small, and :medium as default), label,
  # helper text, validation error message, placeholder, and disabled/readonly states.
  class TextareaComponent < ViewComponent::Base
    SIZES = {
      small: :small,
      medium: :medium,
      sm: :small,
      md: :medium
    }.freeze

    attr_reader :name, :value, :rows, :id, :label, :hint, :error,
      :size, :placeholder, :disabled, :readonly, :required, :html_options

    # Creates a new multi-line text area instance.
    #
    # @param name [String, Symbol, nil] field name attribute
    # @param value [String, nil] text content
    # @param rows [Integer] number of visible text lines (defaults to 3)
    # @param id [String, nil] custom DOM id
    # @param label [String, nil] label text
    # @param hint [String, nil] helper text displayed below the field
    # @param error [String, nil] validation error message displayed below the field
    # @param size [Symbol] field size (:small, :medium; defaults to :medium)
    # @param placeholder [String, nil] placeholder text
    # @param disabled [Boolean] whether the field is disabled
    # @param readonly [Boolean] whether the field is readonly
    # @param required [Boolean] whether the field is required
    # @param html_options [Hash] extra HTML attributes for the textarea tag
    #
    # @return [Ui::TextareaComponent]
    def initialize(
      name = nil,
      value: nil,
      rows: 3,
      id: nil,
      label: nil,
      hint: nil,
      error: nil,
      size: :medium,
      placeholder: nil,
      disabled: false,
      readonly: false,
      required: false,
      **html_options
    )
      @name = name
      @value = value
      @rows = rows
      @id = id
      @label = label
      @hint = hint
      @error = error
      @size = SIZES.fetch(size.to_sym) { :medium }
      @placeholder = placeholder
      @disabled = disabled
      @readonly = readonly
      @required = required
      @html_options = html_options
    end

    # Returns the textarea element ID.
    #
    # @return [String]
    def textarea_id
      @id.presence || (name.present? ? "textarea_#{name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}" : "textarea_#{object_id}")
    end

    # Returns the hint element ID for accessibility.
    #
    # @return [String]
    def hint_id
      "#{textarea_id}_hint"
    end

    # Returns the error element ID for accessibility.
    #
    # @return [String]
    def error_id
      "#{textarea_id}_error"
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

    # Classes for the textarea element.
    #
    # @return [String]
    def textarea_classes
      [
        base_textarea_classes,
        size_classes,
        state_classes,
        html_options[:class]
      ].compact.join(" ")
    end

    # Attributes to forward to the textarea tag.
    #
    # @return [Hash]
    def textarea_tag_attributes
      html_options.except(:class)
        .merge(id: textarea_id, rows: rows, class: textarea_classes)
        .merge(optional_attributes)
        .merge(aria_attributes)
    end

    private

    # Optional and boolean attributes for the textarea tag.
    #
    # @return [Hash]
    def optional_attributes
      {
        name: name.presence,
        placeholder: placeholder.presence,
        disabled: true_or_nil(disabled),
        readonly: true_or_nil(readonly),
        required: true_or_nil(required)
      }.compact
    end

    # Accessibility attributes for the textarea tag.
    #
    # @return [Hash]
    def aria_attributes
      if error?
        {"aria-invalid": "true", "aria-describedby": error_id}
      elsif hint?
        {"aria-describedby": hint_id}
      else
        {}
      end
    end

    # Returns true if condition is truthy, otherwise nil so compact removes it.
    #
    # @param value [Boolean]
    # @return [Boolean, nil]
    def true_or_nil(value)
      true if value
    end

    # Base classes for textarea elements.
    #
    # @return [String]
    def base_textarea_classes
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
