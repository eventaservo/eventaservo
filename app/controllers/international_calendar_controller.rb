# frozen_string_literal: true

class InternationalCalendarController < ApplicationController
  def index
    ahoy.track "Internacia Kalendaro"
    @events = Event.includes([:organizations, :country]).venontaj.international_calendar.order(:date_start)
  end

  def year_list
    @events_by_year = Event.international_calendar.group("EXTRACT (YEAR FROM date_start)").count.sort.reverse.to_h
  end

  def year
    @year = params[:year].to_i
    redirect_to root_url, flash: {error: "Jaro ne validas"} and return if @year < 1887 || @year > 2100

    @events = Event.includes([:country, :organizations]).lau_jaro(@year).international_calendar.order(:date_start)
  end
end
