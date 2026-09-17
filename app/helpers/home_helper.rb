# frozen_string_literal: true

# View helpers for the event filter bar rendered by the home and event
# listing pages.
#
# @see HomeController
module HomeHelper
  # Checks whether the request carries at least one of the supported event
  # filters.
  #
  # @return [Boolean] +true+ when the +o+, +periodo+ or +s+ param is present
  def active_filters?
    params[:periodo].present? || params[:o].present? || params[:s].present?
  end

  # Returns the event filters supported by the filter bar.
  #
  # Only the whitelisted params are returned, so the result is safe to hand
  # back to the URL helpers (for example to keep the current filters while
  # dropping one of them).
  #
  # @return [ActionController::Parameters] permitted +o+, +periodo+ and +s+ params
  def active_filters
    params.permit(:o, :periodo, :s)
  end

  # Returns the display label of an events period filter.
  #
  # The +periodo+ request param carries short machine values, which are mapped
  # here to the Esperanto label rendered to visitors. Values without a known
  # label are returned unchanged, including +nil+.
  #
  # @param period [String, nil] the period value coming from the request
  #
  # @return [String, nil] the display label, or the given value when it has no
  #   known label; +nil+ when the given period is +nil+
  def period_label(period)
    case period
    when "hodiau" then "Okazas nuntempe"
    when "p7_tagojn" then "Proksimajn 7 tagojn"
    when "p30_tagojn" then "Proksimajn 30 tagojn"
    when "estontece" then "Estontece"
    else period
    end
  end
end
