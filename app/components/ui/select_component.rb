# frozen_string_literal: true

module Ui
  # Renders accessible select picker menus styled with Tailwind CSS utilities.
  #
  # Supports options collection, blank option, sizes (:small, and :medium as default),
  # label, helper text, validation error message, and disabled states.
  class SelectComponent < ViewComponent::Base
    SIZES = {
      small: :small,
      medium: :medium,
      sm: :small,
      md: :medium
    }.freeze

    attr_reader :name, :options, :selected, :include_blank, :id,
      :label, :hint, :error, :size, :disabled, :required, :html_options

    # Creates a new select menu instance.
    #
    # @param name [String, Symbol, nil] field name attribute
    # @param options [Array, Enumerable, nil] collection of [label, value] or options
    # @param selected [Object, nil] currently selected value
    # @param include_blank [String, Boolean, nil] blank option label or true
    # @param prompt [String, nil] alternative alias for include_blank
    # @param id [String, nil] custom DOM id
    # @param label [String, nil] label text
    # @param hint [String, nil] helper text
    # @param error [String, nil] validation error message
    # @param size [Symbol] field size (:small, :medium; defaults to :medium)
    # @param disabled [Boolean] whether the field is disabled
    # @param required [Boolean] whether the field is required
    # @param html_options [Hash] extra HTML attributes for the select tag
    #
    # @return [Ui::SelectComponent]
    def initialize(
      name = nil,
      options: [],
      selected: nil,
      include_blank: nil,
      prompt: nil,
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
      @options = options
      @selected = selected
      @include_blank = include_blank || prompt
      @id = id
      @label = label
      @hint = hint
      @error = error
      @size = SIZES.fetch(size.to_sym) { :medium }
      @disabled = disabled
      @required = required
      @html_options = html_options
    end

    # Returns the select element ID.
    #
    # @return [String]
    def select_id
      @id.presence || (name.present? ? "select_#{name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}" : "select_#{object_id}")
    end

    # Returns the hint element ID for accessibility.
    #
    # @return [String]
    def hint_id
      "#{select_id}_hint"
    end

    # Returns the error element ID for accessibility.
    #
    # @return [String]
    def error_id
      "#{select_id}_error"
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

    # Classes for the select element.
    #
    # @return [String]
    def select_classes
      [
        base_select_classes,
        size_classes,
        state_classes,
        html_options[:class]
      ].compact.join(" ")
    end

    # Classes for the select chevron icon wrapper.
    #
    # @return [String]
    def chevron_wrapper_classes
      pad = ((size == :small) ? "tw:pr-2.5" : "tw:pr-3")
      "tw:pointer-events-none tw:absolute tw:inset-y-0 tw:right-0 tw:flex tw:items-center #{pad} tw:text-gray-400"
    end

    # Classes for the chevron icon itself.
    #
    # @return [String]
    def chevron_icon_classes
      case size
      when :small then "fas fa-chevron-down tw:text-[10px]"
      else "fas fa-chevron-down tw:text-xs"
      end
    end

    # Attributes to forward to the select tag.
    #
    # @return [Hash]
    def select_tag_attributes
      html_options.except(:class)
        .merge(id: select_id, class: select_classes)
        .merge(optional_attributes)
        .merge(aria_attributes)
    end

    # Formats normalized options array.
    #
    # @return [Array<Array>]
    def formatted_options
      list = []
      list << blank_option if include_blank
      list.concat(normalized_options)
    end

    private

    # Optional and boolean attributes for the select tag.
    #
    # @return [Hash]
    def optional_attributes
      {
        name: name.presence,
        disabled: true_or_nil(disabled),
        required: true_or_nil(required)
      }.compact
    end

    # Accessibility attributes for the select tag.
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

    # Returns blank option tuple.
    #
    # @return [Array(String, String)]
    def blank_option
      [(include_blank == true) ? "" : include_blank.to_s, ""]
    end

    # Normalizes option collection into array of [label, value] pairs.
    #
    # @return [Array<Array>]
    def normalized_options
      return [] unless options.respond_to?(:each)

      options.map do |item|
        if item.is_a?(Array)
          [item.first.to_s, item.last]
        else
          [item.to_s, item]
        end
      end
    end

    # Base classes for select elements.
    #
    # @return [String]
    def base_select_classes
      "tw:block tw:w-full tw:rounded tw:border tw:transition-colors tw:duration-150 " \
        "tw:bg-white tw:text-gray-900 tw:appearance-none tw:cursor-pointer tw:pr-9"
    end

    # Sizing classes for small and medium.
    #
    # @return [String]
    def size_classes
      case size
      when :small
        "tw:py-1 tw:pl-2.5 tw:text-xs tw:pr-7"
      else # :medium
        "tw:py-1.5 tw:pl-3 tw:text-sm"
      end
    end

    # State classes: normal, disabled, error.
    #
    # @return [String]
    def state_classes
      if disabled
        "tw:border-gray-200 tw:bg-gray-100 tw:text-gray-500 tw:cursor-not-allowed"
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
