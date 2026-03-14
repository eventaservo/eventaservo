# frozen_string_literal: true

module Organizations
  # Query object that filters organizations based on name and country.
  #
  # @example Filter by name
  #   Organizations::SearchQuery.new(name_cont: "UEA").call
  #
  # @example Filter by country
  #   Organizations::SearchQuery.new(country_id_eq: 1).call
  #
  class SearchQuery
    # @return [Hash] the filter parameters
    attr_reader :params
    # @return [ActiveRecord::Relation] the base relation to filter
    attr_reader :relation

    # @param params [Hash] filter parameters (:name_cont, :country_id_eq)
    # @param relation [ActiveRecord::Relation] base scope (defaults to Organization.all)
    def initialize(params = {}, relation = Organization.all)
      @params = params
      @relation = relation
    end

    # Executes the query with the applied filters.
    #
    # @return [ActiveRecord::Relation]
    def call
      organizations = @relation.includes(:country).order(name: :asc)
      organizations = filter_by_name(organizations)
      filter_by_country(organizations)
    end

    private

    # Filters by name using a partial ILIKE match.
    #
    # @param organizations [ActiveRecord::Relation]
    # @return [ActiveRecord::Relation]
    def filter_by_name(organizations)
      return organizations if params[:name_cont].blank?

      organizations.where("organizations.name ILIKE ?", "%#{sanitize(params[:name_cont])}%")
    end

    # Filters by country.
    #
    # @param organizations [ActiveRecord::Relation]
    # @return [ActiveRecord::Relation]
    def filter_by_country(organizations)
      return organizations if params[:country_id_eq].blank?

      organizations.where(country_id: params[:country_id_eq])
    end

    # Sanitizes a string for use in a LIKE query.
    #
    # @param value [Object]
    # @return [String]
    def sanitize(value)
      ActiveRecord::Base.sanitize_sql_like(value.to_s)
    end
  end
end
