# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :filter_events, only: :index
  before_action :definas_kuketojn, only: :index

  def index
    @future_events = Event.venontaj
    if params[:o].present?
      @future_events = @future_events.joins(:organizations).where('organizations.short_name = ?', params[:o])
    end

    @continents    = @events.count_by_continents
    @today_events  = @events.today.includes(:country).includes(:organizations)

    @events = @events.not_today.includes(%i[country organizations])

    if cookies[:vidmaniero] == 'kartoj' # Paghado
      @kvanto_venontaj_eventoj = @events.count
      begin
        @pagy, @events = pagy(@events.not_today.includes(%i[country organizations]))
      rescue Pagy::OverflowError
        redirect_to root_url
      end
    end
  end

  def changelog
  end

  def privateco
  end

  def prie
    render layout: 'full_size'
  end

  def robots
    robots =
      if Rails.env.production?
        File.read(Rails.root + 'config/robots.production.txt')
      else
        File.read(Rails.root + 'config/robots.staging.txt')
      end
    render plain: robots, layout: false, content_type: 'text/plain'
  end

  # Listigas la eventojn por montri per la kalendara vidmaniero
  #
  def events
    redirect_to root_url unless access_from_server

    @events = Event.includes(:country)
    @events = @events.by_continent(params[:continent]) if params[:continent].present?
    @events = @events.by_country_name(params[:country]) if params[:country].present?
    @events = @events.by_city(params[:city]) if params[:city].present?
    @events = @events.lau_organizo(params[:o]) if params[:o].present?
    @events = @events.kun_speco(params[:s]) if params[:s].present?
    @events = Event.includes(:country).by_username(params[:username]) if params[:username].present?
  end

  def feed
    @events = Event.includes(:country).includes(:user).venontaj.order(:date_start)
    render layout: false
  end

  def view_style
    cookies[:vidmaniero] = { value: params[:view_style], expires: 1.year, secure: true }
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
      cookies[:akceptas_ga] = { value: 'jes', expires: 1.year }
    else
      cookies[:akceptas_ga] = { value: 'ne', expires: 1.year }
      delete_ga_cookies
    end

    respond_to do |format|
      format.js
      format.html { redirect_to root_url }
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

    def access_from_server
      request.headers['SERVER_NAME'].in? %w[devel.eventaservo.org staging.eventaservo.org eventaservo.org]
    end

    def definas_kuketojn
      return if cookies[:vidmaniero].in? %w[kartoj kalendaro mapo]

      cookies[:vidmaniero] = { value: 'kartoj', expires: 1.year, secure: true } # Normala vidmaniero
    end
end
