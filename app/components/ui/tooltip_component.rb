# frozen_string_literal: true

# ViewComponent that attaches an accessible Stimulus hint overlay styled with
# Tailwind CSS to icons, badges, or compact trigger elements.
#
class Ui::TooltipComponent < ViewComponent::Base
  PLACEMENTS = {
    top: "top",
    bottom: "bottom",
    left: "left",
    right: "right"
  }.freeze

  attr_reader :text, :placement, :focusable, :html_options

  # Initializes a new floating hint wrapper component.
  #
  # @param text [String] Hint copy displayed on hover or keyboard focus
  # @param placement [Symbol, String] Preferred position (`:top`, `:bottom`, `:left`, `:right`)
  # @param focusable [Boolean] Whether the wrapper receives `tabindex="0"` for non-interactive triggers
  # @param html_options [Hash] Extra HTML attributes merged onto the wrapper `<span>`
  def initialize(text:, placement: :top, focusable: true, **html_options)
    @text = text.to_s
    @placement = normalize_placement(placement)
    @focusable = ActiveModel::Type::Boolean.new.cast(focusable)
    @html_options = html_options
  end

  # Builds HTML attributes for the wrapper element including Stimulus data values.
  #
  # @return [Hash] Merged HTML attribute hash
  def wrapper_attributes
    attrs = html_options.except(:class, :data, :aria)
    attrs[:class] = computed_classes
    attrs[:data] = merged_data_attributes
    attrs[:aria] = merged_aria_attributes if focusable || html_options[:aria].present?

    if focusable
      attrs[:tabindex] = html_options.fetch(:tabindex, 0)
    end

    attrs
  end

  private

  # Computes Tailwind utility classes for the wrapper element.
  #
  # @return [String] Space-separated Tailwind classes
  def computed_classes
    base = if focusable
      "tw:inline-flex tw:items-center tw:rounded tw:focus-visible:outline-none tw:focus-visible:ring-2 tw:focus-visible:ring-esperanto-500/40"
    else
      "tw:inline-flex tw:items-center"
    end

    [base, html_options[:class]].compact.join(" ")
  end

  # Merges Stimulus `hint` controller values with caller-provided `data` options.
  #
  # @return [Hash] Stimulus data hash
  def merged_data_attributes
    extra = (html_options[:data] || {}).transform_keys(&:to_sym)
    controllers = ["hint", extra[:controller]].compact_blank.join(" ")

    extra.merge(
      controller: controllers,
      hint_text_value: text,
      hint_placement_value: PLACEMENTS.fetch(placement)
    )
  end

  # Merges accessible `aria-label` when the wrapper acts as a focusable icon trigger.
  #
  # @return [Hash] Merged ARIA hash
  def merged_aria_attributes
    extra = (html_options[:aria] || {}).transform_keys(&:to_sym)
    return extra unless focusable

    {label: text}.merge(extra)
  end

  # Validates and normalizes the requested placement direction.
  #
  # @param value [Symbol, String] Requested placement key
  # @return [Symbol] Validated placement symbol
  def normalize_placement(value)
    key = value.to_sym
    return key if PLACEMENTS.key?(key)

    raise ArgumentError, "Unknown placement: #{value.inspect}. Valid placements: #{PLACEMENTS.keys.join(", ")}"
  end
end
