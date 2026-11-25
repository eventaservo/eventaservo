# frozen_string_literal: true

class Event
  module Reports
    # Query object that filters event reports by report title and event title.
    #
    # @example Filter by report title
    #   Event::Reports::SearchQuery.new(title: "Raporto").call
    #
    # @example Filter by event title
    #   Event::Reports::SearchQuery.new(event_title: "Kongreso").call
    #
    # @see Admin::ReportsController#index
    class SearchQuery
      attr_reader :params, :relation

      # Initializes the query with filter parameters and an optional base relation.
      #
      # @param params [Hash, ActionController::Parameters] filter parameters
      #   (:title, :event_title)
      # @param relation [ActiveRecord::Relation] base scope (defaults to +Event::Report.all+)
      #
      # @return [void]
      def initialize(params = {}, relation = Event::Report.all)
        @params = params
        @relation = relation
      end

      # Executes the query with the applied filters.
      #
      # @return [ActiveRecord::Relation<Event::Report>] filtered reports ordered newest first
      def call
        reports = relation.includes(:event, :user).order(created_at: :desc)
        reports = filter_by_title(reports)
        filter_by_event_title(reports)
      end

      private

      # Filters by report title using a partial ILIKE match.
      #
      # @param reports [ActiveRecord::Relation<Event::Report>]
      #
      # @return [ActiveRecord::Relation<Event::Report>]
      def filter_by_title(reports)
        return reports if params[:title].blank?

        reports.where("event_reports.title ILIKE ?", "%#{sanitize(params[:title])}%")
      end

      # Filters by associated event title using a partial ILIKE match.
      #
      # @param reports [ActiveRecord::Relation<Event::Report>]
      #
      # @return [ActiveRecord::Relation<Event::Report>]
      def filter_by_event_title(reports)
        return reports if params[:event_title].blank?

        reports.joins(:event).where("events.title ILIKE ?", "%#{sanitize(params[:event_title])}%")
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
end
