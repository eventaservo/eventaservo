# frozen_string_literal: true

module Users
  # Query object that filters and returns teachers (instruistoj) and speakers (prelegantoj).
  #
  # When filter parameters are present, returns matching results ordered by name.
  # When no filters are applied, returns one random teacher and one random speaker.
  #
  # @example With filters
  #   result = Users::TeachersAndSpeakersQuery.new(name: "Ana", level: "baza").call
  #   result.instruistoj # => #<ActiveRecord::Relation [...]>
  #   result.filtering?  # => true
  #
  # @example Without filters (random)
  #   result = Users::TeachersAndSpeakersQuery.new.call
  #   result.filtering?  # => false
  #
  class TeachersAndSpeakersQuery
    attr_reader :name, :country_id, :level, :keyword

    # @param name [String, nil] partial name to match (case-insensitive)
    # @param country_id [String, Integer, nil] country ID to filter by
    # @param level [String, nil] teaching level (e.g. "baza", "meza", "alta")
    # @param keyword [String, nil] keyword to search in expertise/topics
    def initialize(name: nil, country_id: nil, level: nil, keyword: nil)
      @name = name
      @country_id = country_id
      @level = level
      @keyword = keyword
    end

    # Executes the query and returns a Result struct.
    #
    # @return [Result]
    def call
      filtering? ? filtered_results : random_results
    end

    # Returns whether any filter parameter is present.
    #
    # @return [Boolean]
    def filtering?
      name.present? || country_id.present? || level.present? || keyword.present?
    end

    private

    # @return [ActiveRecord::Relation]
    def base_scope
      User.includes([:country, [picture_attachment: :blob]])
    end

    # @return [Result]
    def filtered_results
      filtered = base_scope
      filtered = filtered.where("name ILIKE ?", "%#{sanitize(name)}%") if name.present?
      filtered = filtered.where(country_id: country_id.to_i) if country_id.present?

      instruistoj = filtered.instruistoj.order(:name)
      prelegantoj = filtered.prelegantoj.order(:name)

      instruistoj = instruistoj.where("instruo -> 'nivelo' ? :nivelo", nivelo: level) if level.present?

      if keyword.present?
        kw = "%#{sanitize(keyword)}%"
        instruistoj = instruistoj.where("instruo ->> 'sperto' ILIKE ?", kw)
        prelegantoj = prelegantoj.where("prelego ->> 'temoj' ILIKE ?", kw)
      end

      Result.new(instruistoj:, prelegantoj:, filtering: true)
    end

    # @return [Result]
    def random_results
      Result.new(
        instruistoj: base_scope.instruistoj.order(Arel.sql("RANDOM()")).limit(1),
        prelegantoj: base_scope.prelegantoj.order(Arel.sql("RANDOM()")).limit(1),
        filtering: false
      )
    end

    # Escapes LIKE metacharacters in the given value.
    #
    # @param value [String]
    # @return [String]
    def sanitize(value)
      ActiveRecord::Base.sanitize_sql_like(value)
    end

    # Holds the query results.
    #
    # @!attribute [r] instruistoj
    #   @return [ActiveRecord::Relation] matched teachers
    # @!attribute [r] prelegantoj
    #   @return [ActiveRecord::Relation] matched speakers
    # @!attribute [r] filtering
    #   @return [Boolean] whether filters were applied
    Result = Struct.new(:instruistoj, :prelegantoj, :filtering, keyword_init: true) do
      alias_method :filtering?, :filtering
    end
  end
end
