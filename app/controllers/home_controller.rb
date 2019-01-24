# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    session[:event_list_style] ||= 'listo' # Normala vidmaniero
    @events = Event.includes(:country).venontaj
    @countries = Event.venontaj.count_by_country
    @continents = Event.venontaj.count_by_continents
  end

  def changelog
  end

  def privateco
  end

  def prie
  end

  def events
    @events = Event.includes(:country)
    @events = @events.by_continent(params[:continent]) if params[:continent].present?
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

  def statistics
  end

  def accept_cookies
    if params[:akceptas_ga] == 'jes'
      cookies[:akceptas_ga] = 'jes'
    else
      cookies[:akceptas_ga] = 'ne'
      delete_ga_cookies
    end
  end

  def reset_cookies
    delete_ga_cookies
    cookies.delete :akceptas_ga
    redirect_to root_url
  end

  private

  # Forigas Google Analytics cookies
  def delete_ga_cookies
    cookies.delete :_ga, path: '/', domain: '.eventaservo.org'
    cookies.delete :_gid, path: '/', domain: '.eventaservo.org'
  end
end
