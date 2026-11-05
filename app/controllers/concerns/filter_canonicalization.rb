# frozen_string_literal: true

# Redirects listing requests whose filter parameters are not canonical.
#
# Equivalent or invented combinations are answered with a 301 before any
# query or render, which is the cheap path for crawlers.
module FilterCanonicalization
  extend ActiveSupport::Concern

  included do
    before_action :redirect_to_canonical_filters, if: :canonicalizable_action?
  end

  private

  # Only listing actions take filters; search and feeds keep their own params.
  #
  # @return [Boolean]
  def canonicalizable_action?
    action_name.in?(%w[index show])
  end

  # @return [void]
  def redirect_to_canonical_filters
    return unless canonicalizable_request?

    result = EventFilters::Canonicalizer.call(request.query_parameters)

    raise ActiveRecord::RecordNotFound if result.not_found?
    return if canonical_query?(result.query)

    redirect_to canonical_filter_url(result.query), status: :moved_permanently
  end

  # Requests that carry filters and are rendered as HTML.
  #
  # @return [Boolean]
  def canonicalizable_request?
    return false unless request.get? || request.head?

    !request.format.json? && !request.format.xml? && !request.format.turbo_stream?
  end

  # Compares parsed parameters so encoding differences ("," vs "%2C") and
  # repeated keys do not trigger a redirect loop.
  #
  # @param query [String]
  # @return [Boolean]
  def canonical_query?(query)
    Rack::Utils.parse_nested_query(request.query_string) ==
      Rack::Utils.parse_nested_query(query)
  end

  # @param query [String]
  # @return [String]
  def canonical_filter_url(query)
    query.present? ? "#{request.path}?#{query}" : request.path
  end
end
