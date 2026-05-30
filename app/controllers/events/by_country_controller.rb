# frozen_string_literal: true

# Controller for browsing events by country.
#
# Handles the +/:continent/:country_name+ route, listing events filtered
# by country. Supports card and map view modes.
class Events::ByCountryController < ApplicationController
  include EventBrowsing

  helper EventsHelper

  before_action :validate_continent
  before_action :set_country

  def show
    redirect_to(root_path, flash: {error: "Lando ne ekzistas en la datumbazo"}) && return if @country.nil?

    respond_to do |format|
      format.xml do
        ahoy.track "RSS feed by country", country: @country.code
        render_rss_feed(scope: Event.by_country_id(@country.id))
      end

      format.html do
        if params[:pasintaj].present?
          render_pasintaj_by_country
        else
          unless cookies[:vidmaniero].in? %w[kartaro mapo]
            cookies[:vidmaniero] = {value: "kartaro", expires: 2.weeks, secure: true}
            redirect_to events_by_country_url(continent: @country.continent.normalized, country_name: @country.name.normalized) and return
          end

          @events = build_events_scope
          @future_events = Event.includes(:country).by_country_id(@country.id).venontaj
          @cities = Events::CityCountsQuery.new(scope: @events.venontaj.by_country_id(@country.id)).call
          @today_events = @events.today.includes(:country).by_country_id(@country.id)
          @events = @events.not_today.includes(:country).by_country_id(@country.id)

          setup_card_pagination
        end
      end
    end
  end

  private

  # Sets up assigns for the past-events view on +show+ (country).
  #
  # @return [void]
  def render_pasintaj_by_country
    @past_mode = true
    @events = build_events_scope
    @future_events = Event.none
    @today_events = Event.none
    @cities = Events::CityCountsQuery.new(
      scope: Event.pasintaj.by_country_id(@country.id)
    ).call
    @pagy, @events = pagy(
      @events.by_country_id(@country.id).includes(:country).order(date_start: :desc)
    )
  end
end
