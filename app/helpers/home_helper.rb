# frozen_string_literal: true

module HomeHelper
  def aktivaj_filtroj?
    params[:periodo].present? || params[:o].present? || params[:s].present?
  end

  def aktivaj_filtroj
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
