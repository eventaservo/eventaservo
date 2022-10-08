# frozen_string_literal: true

class InternationalCalendarController < ApplicationController
  def index
    @events = Event.international_calendar.order(:date_start)
  end

  def jaro
    @jaro = params[:jaro].to_i
    redirect_to root_url, flash: { error: 'Jaro ne valida' } and return if (@jaro < 1887 || @jaro > 2100)

    @eventoj = Event.lau_jaro(@jaro).international_calendar.order(:date_start)
  end
end
