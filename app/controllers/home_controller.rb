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
    @ads = Ad.includes([image_attachment: :blob]).active.sample(4)

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

    @instruistoj = User.includes([:country, [picture_attachment: :blob]]).instruistoj.order(:name)
    @prelegantoj = User.includes([:country, [picture_attachment: :blob]]).prelegantoj.order(:name)
  end

  def privateco
    ahoy.track "Visit Privateco"

    respond_to do |format|
      format.html
      format.text do
        render "privateco", layout: false
      end
    end
  end

  def prie
    ahoy.track "Visit Prie"
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

    @events = Event.includes([:country, [uploads_attachments: :blob]])
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
    @search_term = params[:query]&.strip
    if @search_term.blank? || @search_term.length < 3
      @search_is_valid = false
    else
      @search_is_valid = true

      @organizations = Organization.includes(:country).serchi(@search_term).order(:name)
      @users = User.serchi(@search_term)
      @videos = Video.serchi(@search_term)

      @events = Event.includes(%i[country participants organizations]).search(@search_term)
      @events = @events.future_and_just_finished if params[:pasintaj].nil?
      @events = @events.ne_nuligitaj if params[:nuligitaj].nil?
      @events = @events.order(date_start: :desc)
    end
  end

  def versio
    render plain: Eventaservo::Application::VERSION
  end

  # Force an error for testing purposes
  #
  # +GET /dev/error+
  def error
    raise "This is a test error"
  end

  private

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
