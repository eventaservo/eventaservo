# frozen_string_literal: true

module Events
  # Query object that filters events for the administrative listing.
  #
  # Supports switching between active and soft-deleted events (+forigitaj+),
  # date range bounds, partial title search, country and organization filters,
  # and events missing coordinates (+senlokaj+).
  #
  # @example Filter active events by title and country
  #   Events::AdminSearchQuery.new(title: "Kongreso", country_id: 1).call
  #
  # @example List soft-deleted events
  #   Events::AdminSearchQuery.new(forigitaj: "1").call
  #
  # @see Admin::EventsController#index
  class AdminSearchQuery
    attr_reader :params, :relation

    # Initializes the query with filter parameters and an optional base relation.
    #
    # @param params [Hash, ActionController::Parameters] filter parameters
    #   (:forigitaj, :start_date, :end_date, :title, :country_id, :organization_id, :senlokaj)
    # @param relation [ActiveRecord::Relation, nil] optional base scope; when nil,
    #   defaults to +Event.deleted+ if +params[:forigitaj] == "1"+ or +Event.all+
    #
    # @return [void]
    def initialize(params = {}, relation = nil)
      @params = params
      @relation = relation
    end

    # Executes the query with the applied filters.
    #
    # @return [ActiveRecord::Relation<Event>] filtered events ordered by +date_start+ descending
    def call
      events = base_relation.includes(:user, :country, :organizations).order(date_start: :desc)
      events = filter_by_start_date(events)
      events = filter_by_end_date(events)
      events = filter_by_title(events)
      events = filter_by_country(events)
      events = filter_by_organization(events)
      filter_without_location(events)
    end

    private

    # Resolves the base relation according to the +forigitaj+ flag.
    #
    # @return [ActiveRecord::Relation<Event>]
    def base_relation
      return relation if relation

      (params[:forigitaj].to_s == "1") ? Event.deleted : Event.all
    end

    # Filters events starting on or after +params[:start_date]+.
    #
    # @param events [ActiveRecord::Relation<Event>]
    #
    # @return [ActiveRecord::Relation<Event>]
    def filter_by_start_date(events)
      return events if params[:start_date].blank?

      events.where("date_start >= ?", params[:start_date])
    end

    # Filters events starting on or before +params[:end_date]+.
    #
    # @param events [ActiveRecord::Relation<Event>]
    #
    # @return [ActiveRecord::Relation<Event>]
    def filter_by_end_date(events)
      return events if params[:end_date].blank?

      events.where("date_start <= ?", params[:end_date])
    end

    # Filters by title using a partial ILIKE match.
    #
    # @param events [ActiveRecord::Relation<Event>]
    #
    # @return [ActiveRecord::Relation<Event>]
    def filter_by_title(events)
      return events if params[:title].blank?

      events.where("events.title ILIKE ?", "%#{sanitize(params[:title])}%")
    end

    # Filters by country ID.
    #
    # @param events [ActiveRecord::Relation<Event>]
    #
    # @return [ActiveRecord::Relation<Event>]
    def filter_by_country(events)
      return events if params[:country_id].blank?

      events.where(country_id: params[:country_id])
    end

    # Filters by associated organization ID.
    #
    # @param events [ActiveRecord::Relation<Event>]
    #
    # @return [ActiveRecord::Relation<Event>]
    def filter_by_organization(events)
      return events if params[:organization_id].blank?

      events.joins(:organization_events).where(organization_events: {organization_id: params[:organization_id]})
    end

    # Restricts to events without geographic coordinates when +senlokaj+ is +"1"+.
    #
    # @param events [ActiveRecord::Relation<Event>]
    #
    # @return [ActiveRecord::Relation<Event>]
    def filter_without_location(events)
      return events unless params[:senlokaj].to_s == "1"

      events.without_location
    end

    # Sanitizes a string for use in a LIKE query.
    #
    # @param value [Object] raw value to escape
    #
    # @return [String] escaped string safe for LIKE patterns
    def sanitize(value)
      ActiveRecord::Base.sanitize_sql_like(value.to_s)
    end
  end
end
