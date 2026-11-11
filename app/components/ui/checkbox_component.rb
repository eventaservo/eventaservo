# frozen_string_literal: true

module Ui
  # Renders accessible checkbox form inputs styled with Tailwind CSS utilities.
  #
  # Supports checked state, sizes (:small, and :medium as default), label,
  # helper text, validation error message, and disabled states with slightly
  # rounded corners matching Bootstrap standards.
  class CheckboxComponent < ViewComponent::Base
    SIZES = {
      small: :small,
      medium: :medium,
      sm: :small,
      md: :medium
    }.freeze

    attr_reader :name, :value, :checked, :id, :label, :hint, :error,
      :size, :disabled, :required, :html_options

    # Creates a new checkbox input instance.
    #
    # @param name [String, Symbol, nil] field name attribute
    # @param value [Object] checkbox value attribute (defaults to "1")
    # @param checked [Boolean] whether the checkbox is initially checked
    # @param id [String, nil] custom DOM id
    # @param label [String, nil] label text (or provide block content)
    # @param hint [String, nil] helper text displayed below the label
    # @param error [String, nil] validation error message
    # @param size [Symbol] field size (:small, :medium; defaults to :medium)
    # @param disabled [Boolean] whether the checkbox is disabled
    # @param required [Boolean] whether the checkbox is required
    # @param html_options [Hash] extra HTML attributes for the input tag
    #
    # @return [Ui::CheckboxComponent]
    def initialize(
      name = nil,
      value: "1",
      checked: false,
      id: nil,
      label: nil,
      hint: nil,
      error: nil,
      size: :medium,
      disabled: false,
      required: false,
      **html_options
    )
      @name = name
      @value = value
      @checked = checked
      @id = id
      @label = label
      @hint = hint
      @error = error
      @size = SIZES.fetch(size.to_sym) { :medium }
      @disabled = disabled
      @required = required
      @html_options = html_options
    end

    # Returns the checkbox element ID.
    #
    # @return [String]
    def checkbox_id
      @id.presence || (name.present? ? "checkbox_#{name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}" : "checkbox_#{object_id}")
    end

    # Returns the hint element ID for accessibility.
    #
    # @return [String]
    def hint_id
      "#{checkbox_id}_hint"
    end

    # Returns the error element ID for accessibility.
    #
    # @return [String]
    def error_id
      "#{checkbox_id}_error"
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

    # Classes for the label wrapper element.
    #
    # @return [String]
    def wrapper_classes
      cursor = disabled ? "tw:cursor-not-allowed tw:opacity-60" : "tw:cursor-pointer"
      align = hint? ? "tw:items-start" : "tw:items-center"
      "tw:inline-flex #{align} tw:gap-2.5 #{cursor}"
    end

    # Classes for the checkbox input element.
    #
    # @return [String]
    def checkbox_classes
      [
        "tw:custom-checkbox",
        size_classes,
        error_classes,
        html_options[:class]
      ].compact.join(" ")
    end

    # Classes for the label text.
    #
    # @return [String]
    def label_classes
      case size
      when :small
        "tw:text-xs tw:font-medium tw:text-gray-700 tw:leading-4"
      else # :medium
        "tw:text-sm tw:font-medium tw:text-gray-800 tw:leading-5"
      end
    end

    # Attributes to forward to the native input tag.
    #
    # @return [Hash]
    def input_tag_attributes
      attrs = html_options.except(:class)
      attrs[:type] = "checkbox"
      attrs[:name] = name if name.present?
      attrs[:id] = checkbox_id
      attrs[:value] = value
      attrs[:checked] = true if checked
      attrs[:disabled] = true if disabled
      attrs[:required] = true if required
      attrs[:class] = checkbox_classes

      if error?
        attrs[:"aria-invalid"] = "true"
        attrs[:"aria-describedby"] = error_id
      elsif hint?
        attrs[:"aria-describedby"] = hint_id
      end

      attrs
    end

    private

    # Sizing classes for small and medium.
    #
    # @return [String]
    def size_classes
      case size
      when :small
        "tw:w-3.5 tw:h-3.5 tw:rounded-[3px] tw:mt-px"
      else # :medium
        "tw:w-4 tw:h-4 tw:rounded-[4px] tw:mt-px"
      end
    end

    # Error border and ring classes.
    #
    # @return [String, nil]
    def error_classes
      "tw:border-red-500 tw:focus:border-red-500 tw:focus:ring-red-500/20" if error?
    end
  end
end
