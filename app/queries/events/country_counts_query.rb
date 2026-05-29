# frozen_string_literal: true

module Events
  # Counts events grouped by country.
  #
  # @example
  #   Events::CountryCountsQuery.new(scope: Event.venontaj.by_continent("eŭropo")).call
  #   # => [#<Event name: "Francio", code: "fr", continent: "Eŭropo", count: 12>, ...]
  #
  class CountryCountsQuery
    attr_reader :scope

    # @param scope [ActiveRecord::Relation] pre-filtered event relation
    def initialize(scope:)
      @scope = scope
    end

    # Uses +WHERE id IN (subquery)+ instead of chaining directly on the scope
    # so that all scope constraints (filters, limits, etc.) are fully applied
    # before the GROUP BY aggregation.
    #
    # @return [ActiveRecord::Relation] rows with +name+, +code+, +continent+, and +count+ columns
    def call
      Event.where(id: scope)
        .joins(:country)
        .select("countries.name", "countries.code", "countries.continent", "count(events.id) as count")
        .group("countries.name", "countries.code", "countries.continent")
        .order("countries.name")
        .load
    end
  end
end
