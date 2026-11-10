# frozen_string_literal: true

# Previews the pagination component in various pagination states.
class Ui::PaginationComponentPreview < ViewComponent::Preview
  # Displays the first page state with disabled Previous button.
  #
  # @param locale select ["eo", "en", "pt_BR"]
  # @return [String] rendered component
  def first_page(locale: "eo")
    pagy = build_pagy(count: 75, page: 1)
    render Ui::PaginationComponent.new(pagy:, locale:)
  end

  # Displays a middle page state where both Previous and Next are active.
  #
  # @param locale select ["eo", "en", "pt_BR"]
  # @return [String] rendered component
  def middle_page(locale: "eo")
    pagy = build_pagy(count: 75, page: 3)
    render Ui::PaginationComponent.new(pagy:, locale:)
  end

  # Displays the last page state with disabled Next button.
  #
  # @param locale select ["eo", "en", "pt_BR"]
  # @return [String] rendered component
  def last_page(locale: "eo")
    pagy = build_pagy(count: 75, page: 5)
    render Ui::PaginationComponent.new(pagy:, locale:)
  end

  # Displays pagination with gap indicators for large datasets.
  #
  # @param locale select ["eo", "en", "pt_BR"]
  # @return [String] rendered component
  def with_gaps(locale: "eo")
    pagy = build_pagy(count: 300, page: 10)
    render Ui::PaginationComponent.new(pagy:, locale:)
  end

  # Displays a single page state (forced with show_single_page: true).
  #
  # @param locale select ["eo", "en", "pt_BR"]
  # @return [String] rendered component
  def single_page(locale: "eo")
    pagy = build_pagy(count: 10, page: 1)
    render Ui::PaginationComponent.new(pagy:, show_single_page: true, locale:)
  end

  private

  # Builds a mock Pagy instance for component previews.
  #
  # @param count [Integer] total number of items
  # @param page [Integer] current page number
  # @param limit [Integer] items per page
  #
  # @return [Pagy::Offset] configured Pagy instance
  def build_pagy(count:, page:, limit: 15)
    mock_request = Struct.new(:params, :path, :base_url).new({}, "/events", "")
    Pagy::Offset.new(count:, page:, limit:, request: mock_request)
  end
end
