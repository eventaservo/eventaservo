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
    redirect_to root_path, flash: {error: "Lando ne ekzistas"} and return if @country.nil?

    if params[:pasintaj].present?
      setup_past_events_by_city
      return
    end

    unless cookies[:vidmaniero].in? %w[kartaro mapo]
      cookies[:vidmaniero] = {value: "kartaro", expires: 2.weeks, secure: true}
    end

    @events = build_events_scope
    @future_events = Event.by_city(params[:city_name]).venontaj(current_timezone)
    @today_events = @events.today(current_timezone).includes(:country).by_city(params[:city_name])
    @events = @events.not_today(current_timezone).by_city(params[:city_name])

    setup_card_pagination
  end

  private

  # Sets up the view assigns for the past-events listing on +show+ (city).
  #
  # Turns on past mode, scopes +@events+ to past events for the given city
  # ordered newest-first, empties the future and today collections, and
  # paginates the result.
  #
  # @return [Array(Pagy, Array<Event>)] the pagination object and paginated
  #   events, destructured into +@pagy+ and +@events+
  def setup_past_events_by_city
    @past_mode = true
    @events = build_events_scope
    @future_events = Event.none
    @today_events = Event.none
    @pagy, @events = pagy(
      @events.by_city(params[:city_name]).includes(:country).order(date_start: :desc)
    )
  end
end
