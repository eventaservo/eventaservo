class HomeController < ApplicationController
  def index
    session[:event_list_style] == 'kartoj' unless session[:event_list_style] == 'listo' # Normala vidmaniero kiel kartoj
    @events = Event.includes(:country).venontaj.grouped_by_months
    @countries = Event.venontaj.count_by_country
  end

  def privateco
  end

  def prie
  end

  def view_style
    session[:event_list_style] = params[:view_style]
    redirect_back fallback_location: root_url
  end
end
