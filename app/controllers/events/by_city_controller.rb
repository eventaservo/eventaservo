# frozen_string_literal: true

# Controller for browsing events by city.
#
# Handles the +/:continent/:country_name/:city_name+ route, listing events
# filtered by city. Supports card and map view modes.
class Events::ByCityController < ApplicationController
  include EventBrowsing

  helper EventsHelper

  before_action :validate_continent
  before_action :set_country

  def show
    redirect_to root_url, flash: {error: "Lando ne ekzistas"} and return if @country.nil?

    if params[:pasintaj].present?
      render_pasintaj_by_city
      return
    end

    unless cookies[:vidmaniero].in? %w[kartaro mapo]
      cookies[:vidmaniero] = {value: "kartaro", expires: 2.weeks, secure: true}
      redirect_to events_by_city_url(continent: params[:continent].normalized, country_name: params[:country_name].downcase, city_name: params[:city_name].downcase) and return
    end

    @events = build_events_scope
    @future_events = Event.by_city(params[:city_name]).venontaj
    @today_events = @events.today.includes(:country).by_city(params[:city_name])
    @events = @events.not_today.by_city(params[:city_name])

    setup_card_pagination
  end

  private

  # Sets up assigns for the past-events view on +show+ (city).
  #
  # @return [void]
  def render_pasintaj_by_city
    @past_mode = true
    @events = build_events_scope
    @future_events = Event.none
    @today_events = Event.none
    @pagy, @events = pagy(
      @events.by_city(params[:city_name]).includes(:country).order(date_start: :desc)
    )
  end
end
