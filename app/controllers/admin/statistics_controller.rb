# frozen_string_literal: true

module Admin
  class StatisticsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @start_date = parse_date(params[:start_date])
      @end_date = parse_date(params[:end_date])

      # Set defaults if parsing failed or params were missing
      @start_date ||= (Date.today - 11.months).beginning_of_month
      @end_date ||= Date.today.end_of_month

      if @start_date > @end_date
        @start_date, @end_date = @end_date, @start_date
      end

      @range = @start_date..@end_date

      @event_created_by_month = [
        {name: "Retaj", data: Event.online.where(created_at: @range).group_by_month(:created_at).count},
        {name: "Ne retaj", data: Event.not_online.where(created_at: @range).group_by_month(:created_at).count}
      ]
    end

    private

    # Parses a date string safely.
    #
    # @param date_string [String, nil] The date string to parse.
    # @return [Date, nil] The parsed date or nil if invalid.
    def parse_date(date_string)
      return if date_string.blank?
      Date.parse(date_string)
    rescue Date::Error
      nil
    end
  end
end
