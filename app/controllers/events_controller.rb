# frozen_string_literal: true

class EventsController < ApplicationController
  include Webcal
  before_action :authenticate_user!, only: %i[index new create edit update destroy]
  before_action :set_event, only: %i[show edit update destroy]
  before_action :authorize_user, only: %i[edit update destroy]
  before_action :filter_by_period, only: %i[by_continent by_country by_city]
  before_action :validate_continent, only: %i[by_continent by_country by_city]
  before_action :set_country, only: %i[by_country by_city]

  # Montras la uzantajn eventojn
  def index
    @events = Event.includes(:country).by_user(current_user).order(date_start: :desc)
  end

  def show
    respond_to do |format|
      format.html { impressionist(@event, nil, unique: [:session_hash]) }
      format.ics { kreas_webcal(@event) }
    end
  end

  def new
    if params[:from_event].present?
      attributes = Event.find(params[:from_event]).attributes.except('code', 'date_start', 'date_end', 'user_id')
      @event = Event.new(attributes)
    else
      @event = Event.new
      @event.city = current_user.city if current_user.city?
      @event.country_id = current_user.country_id if current_user.country_id?
    end
    @event.date_start = Time.zone.today
    @event.date_end = Time.zone.today
  end

  def edit
  end

  def create
    @event         = Event.new(event_params)
    @event.user_id = current_user.id

    params[:event].each { |_key, value| value.strip! if value.class == 'String' }

    if @event.save
      EventMailer.send_notification_to_users(event_id: @event.id)
      redirect_to event_path(@event.code), flash: { notice: 'Evento sukcese kreita.' }
    else
      render :new
    end
  end

  def update
    if @event.update(event_params)
      redirect_to event_path(@event.code), notice: 'Evento sukcese ĝisdatigita'
    else
      render :edit
    end
  end

  def destroy
    redirect_to(event_path(@event.code), flash: { error: 'Vi ne estas la kreinto, do vi ne rajtas forigi ĝin' }) && return unless current_user.owner_of(@event) || current_user.admin?

    # Ne forviŝas la eventon el la datumbaso nun. Ĝi estos forviŝita post kelkaj tagoj
    @event.delete!
    redirect_to root_url, flash: { error: 'Evento sukcese forigita' }
  end

  def delete_file
    event = Event.by_code(params[:event_code])
    event.uploads.find(params[:file_id]).purge_later
    redirect_to event_path(event.code), flash: { success: 'Dosiero sukcese forigita' }
  end

  def by_continent
    if params[:continent] == 'Reta' && cookies[:vidmaniero] == 'mapo'
      cookies[:vidmaniero] = 'listo'
      redirect_to events_by_continent_path('Reta')
    end

    @future_events = Event.by_continent(params[:continent]).venontaj
    @events        = @events.by_continent(params[:continent])
    @countries     = @events.count_by_country
  end

  def by_country
    redirect_to(root_path, flash: { error: 'Lando ne ekzistas en la datumbazo' }) && return if @country.nil?

    @future_events = Event.includes(:country).by_country_id(@country.id).venontaj
    @cities        = @events.by_country_id(@country.id).count_by_cities
    @events        = @events.includes(:country).by_country_id(@country.id)
  end

  # Listigas la eventoj laŭ urboj
  def by_city
    @future_events = Event.by_city(params[:city_name]).venontaj
    @events        = @events.by_city(params[:city_name])
  end

  def by_username
    redirect_to root_path, flash: { error: 'Uzantnomo ne ekzistas' } if User.find_by(username: params[:username]).nil?

    @events = Event.by_username(params[:username]).venontaj
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.by_code(params[:code])
      redirect_to root_path, flash: { error: 'Evento ne ekzistas' } if @event.nil?
    end

    def set_country
      @country = Country.by_name(params[:country_name])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      if params[:event][:date_start].present?
        params[:event][:date_start] = merge_date_time(params[:event][:date_start], params[:time_start])
        params[:event][:date_end] = merge_date_time(params[:event][:date_end], params[:time_end])
      end
      params.require(:event).permit(
        :title, :description, :content, :site, :email, :date_start, :date_end,
        :address, :city, :country_id, :online, uploads: []
      )
    end

    # Nur la permesataj uzantoj povas redakti, ĝisdatiĝi kaj foriĝi la eventon
    def authorize_user
      unless current_user.owner_of(@event) || current_user.admin?
        redirect_to root_url, flash: { error: 'Vi ne rajtas' }
      end
    end

    def validate_continent
      continent_names = Country.pluck(:continent).uniq

      if params[:continent].normalized.in? continent_names.map(&:normalized)
        @continent = Country.continent_name(params[:continent])
      else
        redirect_to root_url, flash: { notice: 'Ne estas eventoj en tiu kontinento' }
      end
    end

    def merge_date_time(date, time)
      DateTime.strptime("#{date} #{time}", '%d/%m/%Y %H:%M')
    end
end
