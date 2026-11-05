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
    redirect_to root_path, flash: {error: I18n.t("flash.countries.not_found")} and return if @country.nil?

    if params[:pasintaj].present?
      setup_past_events_by_city
      return
    end

    unless cookies[:vidmaniero].in? %w[kartaro mapo]
      cookies[:vidmaniero] = {value: "kartaro", expires: 2.weeks, secure: true}
    end

    setup_nearby_cities
    cities = listed_city_pairs

    @events = build_events_scope
    @future_events = Event.in_cities(cities).venontaj(current_timezone)
    @today_events = @events.today(current_timezone).includes(:country).in_cities(cities)
    @events = @events.not_today(current_timezone).in_cities(cities)

    setup_card_pagination
    setup_nearby_breakdown
  end

  private

  # Computes the count breakdown between the target city and nearby cities
  # for the upcoming events card view when nearby discovery is active.
  #
  # @return [void]
  def setup_nearby_breakdown
    return unless @card_view && @include_nearby && @nearby_cities.present?

    target_city_scope = [[params[:city_name], @country.id]]
    @target_city_events_count = build_events_scope.not_today(current_timezone).in_cities(target_city_scope).count
    @nearby_events_count = @kvanto_venontaj_eventoj.to_i - @target_city_events_count
    @nearby_radius_km = Events::NearbyCitiesQuery::DEFAULT_RADIUS_KM
    @target_city_name = Event.by_city(params[:city_name]).by_country_id(@country.id).order(:id).pick(:city) || params[:city_name]
  end

  # Sets up the nearby-cities assigns used by the card view.
  #
  # Nearby events are shown by default (opt-out model) and hidden when
  # +cookies[:nearby]+ is set to +"0"+. They only apply to the card view;
  # the map view stays scoped to the target city.
  #
  # @return [void]
  def setup_nearby_cities
    @card_view = cookies[:vidmaniero].in?(%w[kartoj kartaro])
    @include_nearby = cookies[:nearby] != "0"
    @nearby_cities = @card_view ? Events::NearbyCitiesQuery.new(city_name: params[:city_name], country_id: @country.id).call : []
  end

  # The [city, country_id] pairs whose events are listed on the page.
  #
  # Always includes the target city; adds the nearby cities when the card view
  # is active and nearby events have not been hidden.
  #
  # @return [Array<Array(String, Integer)>]
  def listed_city_pairs
    target = [[params[:city_name], @country.id]]
    @include_nearby ? target + @nearby_cities : target
  end

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
