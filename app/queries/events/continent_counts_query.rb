# frozen_string_literal: true

module Events
  # Counts events grouped by continent.
  #
  # @example Count future events by continent
  #   Events::ContinentCountsQuery.new(scope: Event.venontaj.chefaj).call
  #   # => [#<Event name: "eŭropo", count: 42>, ...]
  #
  class ContinentCountsQuery
    attr_reader :scope

    # @param scope [ActiveRecord::Relation] pre-filtered event relation
    def initialize(scope:)
      @scope = scope
    end

    # Uses +WHERE id IN (subquery)+ instead of chaining directly on the scope
    # so that all scope constraints (filters, limits, etc.) are fully applied
    # before the GROUP BY aggregation.
    #
    # @return [ActiveRecord::Relation] rows with +name+ (continent) and +count+ columns
    def call
      Event.where(id: scope)
        .joins(:country)
        .select("countries.continent as name", "count(events.id)")
        .group("countries.continent")
        .order("countries.continent")
        .load
    end
  end
end
