class HomeController < ApplicationController
  def index
    session[:event_list_style] ||= 'kalendaro' # Normala vidmaniero
    @events = Event.includes(:country).venontaj.grouped_by_months
    @countries = Event.venontaj.count_by_country
  end

  def privateco
    render formats: :text
  end

  def prie
  end

  def events
    @events = Event.includes(:country)
    @events = @events.by_country_name(params[:country]) if params[:country].present?
    @events = @events.by_city(params[:city]) if params[:city].present?
    @events = Event.includes(:country).by_username(params[:username]) if params[:username].present?
  end

  def view_style
    session[:event_list_style] = params[:view_style]
    redirect_back fallback_location: root_url
  end

  def search
    respond_to :js
    @events = Event.includes(:country).search(params[:query]).venontaj.grouped_by_months
  end
end
