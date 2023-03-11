# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :filter_events, only: :index
  before_action :definas_kuketojn, only: :index

  def index
    ahoy.track "Homepage"

    @future_events = Event.venontaj
    if params[:o].present?
      @future_events = @future_events.joins(:organizations).where("organizations.short_name = ?", params[:o])
    end

    @continents = @events.count_by_continents
    @today_events = @events.today.includes(:country).includes(:organizations)

    @events = @events.not_today.includes(%i[country organizations])
    @reklamoj = Ad.includes([image_attachment: :blob]).active.sample(4)

    return if cookies[:vidmaniero].in? %w[kalendaro mapo]

    cookies[:vidmaniero] = {value: "kalendaro", expires: 2.weeks, secure: true}
    redirect_to root_url
  end

  def anoncoj
    ahoy.track "Visit Anoncoj"

    @eventoj = Event.anoncoj_kaj_konkursoj.venontaj
  end

  def instruistoj_kaj_prelegantoj
    ahoy.track "Visit Instruantoj kaj Prelegantoj"

    @instruistoj = User.instruistoj.order(:name)
    @prelegantoj = User.prelegantoj.order(:name)
  end

  def privateco
    ahoy.track "Visit Privateco"

    respond_to do |format|
      format.html
      format.text do
        render "privateco.txt", layout: false
      end
    end
  end

  def prie
    ahoy.track "Visit Prie"
    render layout: "full_size"
  end

  def changes
    ahoy.track "Visit Novaĵoj"
  end

  def robots
    ahoy.track "Read /robots.txt"

    robots =
      if Rails.env.production?
        File.read(Rails.root + "config/robots.production.txt")
      else
        File.read(Rails.root + "config/robots.staging.txt")
      end
    render plain: robots, layout: false, content_type: "text/plain"
  end

  # Listigas la eventojn por montri per la kalendara vidmaniero
  #
  def events
    redirect_to root_url unless access_from_server

    @horzono = cookies[:horzono]
    @events = Event.ne_nuligitaj.chefaj.includes(:country)
    @events = @events.by_dates(from: params[:start], to: params[:end])
    @events = @events.by_continent(params[:continent]) if params[:continent].present?
    @events = @events.by_country_name(params[:country]) if params[:country].present?
    @events = @events.by_city(params[:city]) if params[:city].present?
    @events = @events.lau_organizo(params[:o]) if params[:o].present?
    @events = @events.kun_speco(params[:s]) if params[:s].present?
    @events = @events.unutagaj if params[:t] == "unutaga"
    @events = @events.plurtagaj if params[:t] == "plurtaga"
    @events = Event.includes(:country).by_username(params[:username]) if params[:username].present?
  end

  def feed
    ahoy.track "Rendered feed"

    @events = Event.includes(%i[country uploads_attachments])
      .venontaj
      .ne_nuligitaj
      .ne_anoncoj
      .where(cancelled: false)
      .order(:date_start)

    render layout: false
  end

  def view_style
    cookies[:vidmaniero] = {value: params[:view_style], expires: 1.year, secure: true}
    redirect_to root_url
  end

  def search
    @events = Event.includes(%i[country participants]).search(params[:query])
    @organizations = Organization.serchi(params[:query]).order(:name)

    @events = @events.venontaj if params[:pasintaj].nil?
    @events = @events.ne_nuligitaj if params[:nuligitaj].nil?

    @users = User.serchi(params[:query])
    @videos = Video.serchi(params[:query])

    @events = @events.order(:date_start)
  end

  def statistics
    ahoy.track "Visit Statistics"

    respond_to do |format|
      format.html
      format.json do
        case params[:q]
        when "registritaj_eventoj"
          render json: kalkulas_registritajn_eventojn
        when "kvanto_registritaj_uzantoj"
          render json: kalkulas_kvanton_registritaj_uzantoj
        when "kvanto_registritaj_eventoj"
          render json: kalkulas_kvanton_registritaj_eventoj
        when "eventoj_lau_monatoj"
          render json: kalkulas_eventojn_lau_monatoj
        when "eventoj_retaj_kaj_fizikaj"
          render json: kalkulas_eventojn_retajn_kaj_fizikajn
        else
          render json: {eraro: "Ne valida diagramo"}
        end
      end
    end
  end

  def accept_cookies
    if params[:akceptas_ga] == "jes"
      cookies[:akceptas_ga] = {value: "jes", expires: 1.year}
    else
      cookies[:akceptas_ga] = {value: "ne", expires: 1.year}
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

  def versio
    render plain: Constants::VERSIO
  end

  private

  # Forigas Google Analytics cookies
  def delete_ga_cookies
    cookies.delete :_ga, path: "/", domain: ".eventaservo.org"
    cookies.delete :_gid, path: "/", domain: ".eventaservo.org"
  end

  def access_from_server
    request.headers["SERVER_NAME"].in? %w[testservilo.eventaservo.org staging.eventaservo.org
      eventaservo.org localhost 127.0.0.1]
  end

  def definas_kuketojn
    return if cookies[:vidmaniero].in? %w[kartoj kalendaro mapo]

    cookies[:vidmaniero] = {value: "kalendaro", expires: 2.weeks, secure: true} # Normala vidmaniero
  end

  def kalkulas_registritajn_eventojn
    countries = []
    quantity = []
    Event.joins(:country).group("countries.name").order("count_id DESC, countries.name ASC").limit(15).count(:id).map do |country, qtd|
      countries << country
      quantity << qtd
    end
    {landoj: countries, kvantoj: quantity}
  end

  def kalkulas_kvanton_registritaj_uzantoj
    quantity = []
    quantity << User.where("created_at <= ?", (Time.zone.today - 11.months).end_of_month).count
    quantity << User.where("created_at <= ?", (Time.zone.today - 10.months).end_of_month).count
    quantity << User.where("created_at <= ?", (Time.zone.today - 9.months).end_of_month).count
    quantity << User.where("created_at <= ?", (Time.zone.today - 8.months).end_of_month).count
    quantity << User.where("created_at <= ?", (Time.zone.today - 7.months).end_of_month).count
    quantity << User.where("created_at <= ?", (Time.zone.today - 6.months).end_of_month).count
    quantity << User.where("created_at <= ?", (Time.zone.today - 5.months).end_of_month).count
    quantity << User.where("created_at <= ?", (Time.zone.today - 4.months).end_of_month).count
    quantity << User.where("created_at <= ?", (Time.zone.today - 3.months).end_of_month).count
    quantity << User.where("created_at <= ?", (Time.zone.today - 2.months).end_of_month).count
    quantity << User.where("created_at <= ?", (Time.zone.today - 1.month).end_of_month).count
    quantity << User.where("created_at <= ?", Time.zone.today.end_of_month).count

    {monatoj: last_12_months_label, kvantoj: quantity}
  end

  def kalkulas_kvanton_registritaj_eventoj
    quantity = []
    quantity << Event.where("created_at <= ?", (Time.zone.today - 11.months).end_of_month).count
    quantity << Event.where("created_at <= ?", (Time.zone.today - 10.months).end_of_month).count
    quantity << Event.where("created_at <= ?", (Time.zone.today - 9.months).end_of_month).count
    quantity << Event.where("created_at <= ?", (Time.zone.today - 8.months).end_of_month).count
    quantity << Event.where("created_at <= ?", (Time.zone.today - 7.months).end_of_month).count
    quantity << Event.where("created_at <= ?", (Time.zone.today - 6.months).end_of_month).count
    quantity << Event.where("created_at <= ?", (Time.zone.today - 5.months).end_of_month).count
    quantity << Event.where("created_at <= ?", (Time.zone.today - 4.months).end_of_month).count
    quantity << Event.where("created_at <= ?", (Time.zone.today - 3.months).end_of_month).count
    quantity << Event.where("created_at <= ?", (Time.zone.today - 2.months).end_of_month).count
    quantity << Event.where("created_at <= ?", (Time.zone.today - 1.month).end_of_month).count
    quantity << Event.where("created_at <= ?", Time.zone.today.end_of_month).count

    {monatoj: last_12_months_label, kvantoj: quantity}
  end

  def kalkulas_eventojn_lau_monatoj
    monatoj = %w[
      Jan
      Feb
      Mar
      Apr
      Maj
      Jun
      Jul
      Aŭg
      Sep
      Okt
      Nov
      Dec
    ]

    quantity = []
    (1..12).each do |month|
      quantity << Event.where("extract(month from date_start) = :month OR extract(month from date_end) = :month",
        month: month).count
    end

    {monatoj: monatoj, kvantoj: quantity}
  end

  def kalkulas_eventojn_retajn_kaj_fizikajn
    monatoj = %w[
      Jan
      Feb
      Mar
      Apr
      Maj
      Jun
      Jul
      Aŭg
      Sep
      Okt
      Nov
      Dec
    ]

    eventoj = []
    retaj = []
    fizikaj = []

    11.downto(0) do |m|
      retaj << Event.online.where(created_at: (Date.today - m.month).all_month).count
      fizikaj << Event.not_online.where(created_at: (Date.today - m.month).all_month).count
    end

    eventoj << {name: "Fizikaj", data: fizikaj}
    eventoj << {name: "Retaj", data: retaj}

    {eventoj: eventoj, x_axis: last_12_months_label}
  end
end
