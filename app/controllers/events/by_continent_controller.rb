# frozen_string_literal: true

# Controller for browsing events by continent.
#
# Handles the +/:continent+ route, listing events filtered by continent.
# Supports card, map, and calendar view modes.
class Events::ByContinentController < ApplicationController
  include CalendarData
  include EventBrowsing

  helper EventsHelper

  before_action :validate_continent

  def show
    if params[:continent] != params[:continent].normalized
      redirect_to events_by_continent_path(continent: params[:continent].normalized) and return
    end

    respond_to do |format|
      format.xml do
        ahoy.track "RSS feed by continent", continent: params[:continent]
        render_rss_feed(scope: Event.by_continent(params[:continent]))
      end

      format.html do
        if params[:pasintaj].present?
          render_pasintaj_by_continent
        else
          if params[:continent] == "reta" && cookies[:vidmaniero] != "kalendaro"
            cookies[:vidmaniero] = {value: "kalendaro", expires: 2.weeks, secure: true}
          elsif params[:continent] != "reta"
            unless cookies[:vidmaniero].in? %w[kartaro mapo]
              cookies[:vidmaniero] = {value: "kartaro", expires: 2.weeks, secure: true}
            end
          end

          @events = build_events_scope
          continent_events_base = @events.by_continent(params[:continent])

          @future_events = continent_events_base.venontaj
          @countries = Events::CountryCountsQuery.new(scope: continent_events_base.venontaj).call
          @today_events = continent_events_base.today.includes(:country)
          @events = continent_events_base.not_today.includes(:country, :organizations)

          if cookies[:vidmaniero] == "kalendaro"
            @events = continent_events_base.includes(:country, :organizations)
            prepare_calendar_data
          end

          setup_card_pagination if cookies[:vidmaniero] == "kartaro"
        end
      end
    end
  end

  private

  # Sets up assigns for the past-events view on +show+ (continent).
  # Skips the kartaro/mapo cookie dance and forces a cards-style render
  # ordered newest-first with pagination.
  #
  # @return [void]
  def render_pasintaj_by_continent
    @past_mode = true
    @events = build_events_scope
    continent_events_base = @events.by_continent(params[:continent])
    @future_events = Event.none
    @today_events = Event.none
    @countries = Events::CountryCountsQuery.new(
      scope: Event.pasintaj.by_continent(params[:continent])
    ).call
    @pagy, @events = pagy(
      continent_events_base.includes(:country, :organizations).order(date_start: :desc)
    )
  end
end
