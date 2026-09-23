# frozen_string_literal: true

module Events
  # Counts registered events grouped by country and returns the fifteen
  # countries with the most events.
  #
  # The result is a chart-ready pair of parallel series: +:countries+ holds the
  # country names and +:counts+ the matching event counts, both in descending
  # count order (ties broken alphabetically by country name).
  #
  # @example
  #   Events::TopCountriesCountQuery.new.call
  #   # => {countries: ["Brazilio", "Francio"], counts: [42, 17]}
  #
  # @see Events::CountryCountsQuery
  class TopCountriesCountQuery
    # Returns the top fifteen countries and their event counts.
    #
    # @return [Hash{Symbol => Array<String>, Array<Integer>}] +:countries+ with
    #   the country names and +:counts+ with the matching event counts
    def call
      counts_by_country = Event.joins(:country)
        .group("countries.name")
        .order("count_id DESC, countries.name ASC")
        .limit(15)
        .count(:id)

      {countries: counts_by_country.keys, counts: counts_by_country.values}
    end
  end
end
