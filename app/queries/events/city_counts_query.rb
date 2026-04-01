# frozen_string_literal: true

module Events
  # Counts events grouped by city.
  #
  # @example
  #   Events::CityCountsQuery.new(scope: Event.venontaj.by_country_id(30)).call
  #   # => [#<Event name: "Rio de Janeiro", count: 5>, ...]
  #
  class CityCountsQuery
    attr_reader :scope

    # @param scope [ActiveRecord::Relation] pre-filtered event relation
    def initialize(scope:)
      @scope = scope
    end

    # Uses +WHERE id IN (subquery)+ instead of chaining directly on the scope
    # so that all scope constraints (filters, limits, etc.) are fully applied
    # before the GROUP BY aggregation.
    #
    # @return [ActiveRecord::Relation] rows with +name+ (city) and +count+ columns
    def call
      Event.where(id: scope)
        .select("events.city as name", "count(events.id)")
        .group(:city)
        .order(:city)
        .load
    end
  end
end
