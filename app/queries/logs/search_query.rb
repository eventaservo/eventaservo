# frozen_string_literal: true

module Logs
  # Query object that filters system logs based on user, text and date ranges.
  #
  # @example Filter by user name
  #   Logs::SearchQuery.new(user_name: "Ana").call
  #
  # @example Filter by date range
  #   Logs::SearchQuery.new(start_date: "2026-03-01", end_date: "2026-03-31").call
  #
  class SearchQuery
    # @return [Hash] the filter parameters
    attr_reader :params
    # @return [ActiveRecord::Relation] the base relation to filter
    attr_reader :relation

    # @param params [Hash] filter parameters (:user_name, :text, :start_date, :end_date)
    # @param relation [ActiveRecord::Relation] base scope (defaults to Log.all)
    def initialize(params = {}, relation = Log.all)
      @params = params
      @relation = relation
    end

    # Executes the query with the applied filters.
    #
    # @return [ActiveRecord::Relation]
    def call
      logs = @relation.includes(:user).order(created_at: :desc)
      logs = filter_by_user(logs)
      logs = filter_by_text(logs)
      filter_by_date(logs)
    end

    private

    # Filters by user name using a partial ILIKE match.
    #
    # @param logs [ActiveRecord::Relation]
    # @return [ActiveRecord::Relation]
    def filter_by_user(logs)
      return logs if params[:user_name].blank?

      logs.joins(:user).where("users.name ILIKE ?", "%#{sanitize(params[:user_name])}%")
    end

    # Filters by log text using a partial ILIKE match.
    #
    # @param logs [ActiveRecord::Relation]
    # @return [ActiveRecord::Relation]
    def filter_by_text(logs)
      return logs if params[:text].blank?

      logs.where("logs.text ILIKE ?", "%#{sanitize(params[:text])}%")
    end

    # Filters by created_at date range.
    #
    # @param logs [ActiveRecord::Relation]
    # @return [ActiveRecord::Relation]
    def filter_by_date(logs)
      filtered_logs = logs
      if params[:start_date].present?
        begin
          parsed_date = Time.zone.parse(params[:start_date])
          filtered_logs = filtered_logs.where("logs.created_at >= ?", parsed_date.beginning_of_day) if parsed_date
        rescue ArgumentError, TypeError
          # Ignore invalid dates
        end
      end

      if params[:end_date].present?
        begin
          parsed_date = Time.zone.parse(params[:end_date])
          filtered_logs = filtered_logs.where("logs.created_at <= ?", parsed_date.end_of_day) if parsed_date
        rescue ArgumentError, TypeError
          # Ignore invalid dates
        end
      end

      filtered_logs
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
