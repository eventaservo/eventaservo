module Admin
  class StatisticsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @start_date = params[:start_date].presence ? Date.parse(params[:start_date]) : (Date.today - 11.months).beginning_of_month
      @end_date = params[:end_date].presence ? Date.parse(params[:end_date]) : Date.today.end_of_month

      if @start_date > @end_date
        @start_date, @end_date = @end_date, @start_date
      end

      @range = @start_date..@end_date

      @event_created_by_month = [
        {name: "Retaj", data: Event.online.where(created_at: @range).group_by_month(:created_at).count},
        {name: "Ne retaj", data: Event.not_online.where(created_at: @range).group_by_month(:created_at).count}
      ]
    rescue Date::Error
      @start_date = (Date.today - 11.months).beginning_of_month
      @end_date = Date.today.end_of_month
      retry
    end
  end
end
