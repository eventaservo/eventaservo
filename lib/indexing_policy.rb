# frozen_string_literal: true

# Decides the indexing directives for a response.
#
# Filtered listings (`date`, organization, countries, pagination) generate
# thousands of distinct URLs for the same content. They stay crawlable but are
# marked `noindex` and point to the clean path through a canonical link, so a
# crawler cannot turn the calendar into an endless set of pages.
#
# The staging environment is never indexed at all: it exists for testing and a
# crawler spending requests there only costs CPU.
module IndexingPolicy
  # Query parameters that turn a listing into a filtered variant.
  FILTER_PARAMS = %w[date o s next pagho pasintaj].freeze

  module_function

  # Whether the request carries any filter parameter.
  #
  # @param params [Hash, ActionController::Parameters] request parameters
  # @return [Boolean]
  def filtered?(params)
    FILTER_PARAMS.any? { |key| params.key?(key) }
  end

  # Returns the X-Robots-Tag value for the response.
  #
  # @param environment [String] Rails environment name
  # @param filtered [Boolean] whether the request is a filtered listing
  # @return [String, nil] directive value, or nil when no header is needed
  def robots_tag(environment:, filtered:)
    return "noindex, nofollow" if environment == "staging"
    return "noindex, follow" if filtered

    nil
  end
end
