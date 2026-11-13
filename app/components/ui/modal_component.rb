# frozen_string_literal: true

# ViewComponent that renders an accessible native `<dialog>` overlay styled
# with Tailwind CSS and controlled via the Stimulus `dialog` controller.
#
class Ui::ModalComponent < ViewComponent::Base
  renders_one :trigger
  renders_one :footer

  SIZES = {
    sm: "tw:max-w-md",
    md: "tw:max-w-lg",
    lg: "tw:max-w-3xl"
  }.freeze

  attr_reader :id, :title, :title_id, :size, :auto_focus, :open, :close_label,
    :padded, :scrollable, :overflow_visible, :dialog_data

  # Initializes a new dialog component.
  #
  # @param id [String] DOM id of the `<dialog>` element
  # @param title [String] Heading text rendered inside the dialog header
  # @param title_id [String, nil] Custom DOM id for the heading referenced by `aria-labelledby`
  # @param size [Symbol] Width preset (`:sm`, `:md`, or `:lg`)
  # @param auto_focus [Boolean] Whether opening focuses the first interactive element inside
  # @param open [Boolean] Whether the dialog opens automatically when connected
  # @param close_label [String, nil] Accessible label for the header close icon button
  # @param padded [Boolean] Whether default body padding classes wrap the main content
  # @param scrollable [Boolean] Whether the body region scrolls vertically within viewport height
  # @param overflow_visible [Boolean] Whether content may extend outside `<dialog>` bounds instead of scrolling within the viewport
  # @param dialog_data [Hash] Extra Stimulus/data attributes merged onto `<dialog>`
  def initialize(
    id:,
    title:,
    title_id: nil,
    size: :md,
    auto_focus: true,
    open: false,
    close_label: nil,
    padded: true,
    scrollable: false,
    overflow_visible: false,
    dialog_data: {}
  )
    @id = id.to_s
    @title = title
    @title_id = (title_id || "#{@id}Title").to_s
    @size = normalize_size(size)
    @auto_focus = ActiveModel::Type::Boolean.new.cast(auto_focus)
    @open = ActiveModel::Type::Boolean.new.cast(open)
    @close_label = close_label
    @padded = padded
    @scrollable = scrollable
    @overflow_visible = ActiveModel::Type::Boolean.new.cast(overflow_visible)
    @dialog_data = dialog_data || {}
  end

  # Computes Tailwind utility classes applied to `<dialog>`.
  #
  # @return [String] Space-separated Tailwind classes
  def dialog_classes
    overflow_class = overflow_visible ? "tw:overflow-visible" : "tw:max-h-[90dvh] tw:overflow-y-auto"

    [
      "tw:w-[calc(100%-2rem)]",
      SIZES.fetch(size),
      "tw:m-auto tw:p-0",
      overflow_class,
      "tw:rounded-xl tw:border tw:border-solid tw:border-gray-300",
      "tw:bg-white tw:text-gray-900 tw:shadow-2xl",
      "tw:backdrop:bg-gray-900/50",
      "tw:focus:outline-none"
    ].join(" ")
  end

  # Computes Tailwind utility classes applied to the body region.
  #
  # @return [String] Space-separated Tailwind classes
  def body_classes
    base = "tw:px-6 tw:py-5"
    scrollable ? "#{base} tw:overflow-y-auto tw:max-h-[70vh]" : "#{base} tw:overflow-visible"
  end

  # Computes Tailwind utility classes applied to the footer action region.
  #
  # @return [String] Space-separated Tailwind classes
  def footer_classes
    [
      "tw:flex tw:flex-wrap tw:items-center tw:justify-end tw:gap-2",
      "tw:border-0 tw:border-t tw:border-solid tw:border-gray-200",
      "tw:bg-gray-50 tw:px-6 tw:py-3.5 tw:rounded-b-xl"
    ].join(" ")
  end

  # Resolves data attributes for the `<dialog>` element, merging any extra
  # Stimulus controllers or actions passed via `dialog_data`.
  #
  # @return [Hash] HTML data attributes hash
  def resolved_dialog_data
    extra = dialog_data.transform_keys(&:to_sym)
    controllers = ["dialog", extra[:controller]].compact_blank.join(" ")
    actions = ["click->dialog#backdropClose", extra[:action]].compact_blank.join(" ")

    extra.merge(
      controller: controllers,
      action: actions,
      dialog_open_on_connect_value: open,
      dialog_auto_focus_value: auto_focus
    )
  end

  # Resolves the accessible aria-label for the header close button.
  #
  # @return [String] Localized close label
  def resolved_close_label
    close_label.presence || I18n.t("buttons.close")
  end

  private

  # Validates and normalizes the requested size preset.
  #
  # @param value [Symbol, String] Requested size key
  # @return [Symbol] Validated size symbol
  def normalize_size(value)
    key = value.to_sym
    return key if SIZES.key?(key)

    raise ArgumentError, "Unknown dialog size: #{value.inspect}. Valid sizes: #{SIZES.keys.join(", ")}"
  end
end
