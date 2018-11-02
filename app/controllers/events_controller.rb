# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate_user!, only: %i[index new create edit update destroy]
  before_action :set_event, only: %i[show edit update destroy]
  before_action :authorize_user, only: %i[edit update destroy]

  # Montras la uzantajn eventojn
  def index
    @events = Event.includes(:country).by_user(current_user).order(date_start: :desc)
  end

  def show
  end

  def new
    @event = Event.new
    @event.date_start = Date.today
    @event.date_end = Date.today
    @event.city = current_user.city if current_user.city?
    @event.country_id = current_user.country_id if current_user.country_id?
  end

  def edit
  end

  def create
    @event         = Event.new(event_params)
    @event.user_id = current_user.id

    if @event.save
      @event.participants.create!(user: current_user)
      @event.likes.create!(user: current_user)
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
    redirect_to event_path(@event.code), flash: { error: 'Vi ne estas la kreinto, do vi ne rajtas forigi ĝin' } and return unless current_user.is_owner_of(@event)

    @event.destroy
    redirect_to root_url, flash: { error: 'Evento skcese forigita' }
  end

  def by_country
    @country = Country.find_by(name: params[:country_name])
    redirect_to root_path, flash: { error: 'Lando ne ekzistas en la datumbazo' } and return if @country.nil?
    @events = Event.by_country_id(@country.id).venontaj.grouped_by_months
    @cities = Event.by_country_id(@country.id).venontaj.count_by_cities
  end

  def by_city
    @country = Country.find_by(name: params[:country_name])
    @events = Event.by_city(params[:city_name]).venontaj.grouped_by_months
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find_by(code: params[:code])
    redirect_to root_path, flash: { error: 'Evento ne ekzistas' } if @event.nil?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:title, :description, :content, :address, :date_start, :date_end, :city, :country_id,
                                  { attachments: [] })
  end

  # Nur la permesataj uzantoj povas redakti, ĝisdatiĝi kaj foriĝi la eventon
  def authorize_user
    unless current_user.is_owner_of(@event) || current_user.admin?
      redirect_to root_url, flash: { error: 'Vi ne rajtas'}
    end
  end
end
