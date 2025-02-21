# frozen_string_literal: true

class EventsController < ApplicationController
  rescue_from ActionController::UnknownFormat do |_e|
    redirect_to root_url, flash: {error: "Formato ne ekzistas."}
  end
  include Webcal
  before_action :authenticate_user!, only: %i[index new create edit update destroy nova_importado importi]
  before_action :redirect_old_link, only: %i[show edit]
  before_action :set_event, only: %i[show edit update destroy kronologio]
  before_action :authorize_user, only: %i[edit update destroy]
  before_action :filter_events, only: %i[by_continent by_country by_city]
  before_action :validate_continent, only: %i[by_continent by_country by_city]
  before_action :set_country, only: %i[by_country by_city]
  before_action :sanitize_params

  invisible_captcha only: :kontakti_organizanton, honeypot: :tiel, on_spam: :spam_detected

  # Montras la uzantajn eventojn
  # This action is probable deprecated and it is required to explore if can be removed
  def index
    @events = Event.includes(:country).by_user(current_user).order(date_start: :desc)
  end

  def show
    ahoy.track "Show event", event_url: @event.short_url

    @horzono = cookies[:horzono] || params[:horzono] || @event.time_zone
    @partoprenontoj = @event.participants

    respond_to do |format|
      format.html
      format.ics { kreas_webcal(@event) }
    end
  rescue ActionView::Template::Error => e
    Sentry.capture_exception(e)
    redirect_to root_url, flash: {error: "Eraro okazis montrante tiun eventon"}
  end

  def new
    if params[:from_event].present?
      origin = Event.find(params[:from_event])
      attributes = origin.attributes.except("content", "code", "user_id", "short_url")
      @event = Event.new(attributes)
      @event.date_start = attributes["date_start"].in_time_zone(attributes["time_zone"])
      @event.date_end = attributes["date_end"].in_time_zone(attributes["time_zone"])
      @event.specolisto = origin.specolisto
      @event_organization_ids = origin.organizations.pluck(:id)
      @event.user_id = origin.user_id
    else
      @event = Event.new
      @event.city = current_user.city if current_user.city?
      @event.country_id = current_user.country_id if current_user.country_id?
      @event.date_start = DateTime.new(Date.today.year, Date.today.month, Date.today.day, 0, 0, 0, "0")
      @event.date_end = @event.date_start
    end
  end

  def edit
    @event_organization_ids = @event.organizations.pluck(:organization_id)
  end

  def create
    @event = Event.new(event_params)
    @event.user_id ||= current_user.id

    if @event.save
      @event.update_event_organizations(params[:organization_ids])
      set_event_format(@event)
      NovaEventaSciigoJob.perform_later(@event)
      ahoy.track "Create event", event_url: @event.short_url
      Log.create(text: "Created event #{@event.title}", user: @current_user, event_id: @event.id)
      redirect_to event_path(code: @event.ligilo), flash: {notice: "Evento sukcese kreita."}
    else
      render :new
    end
  end

  def update # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    if dosier_alshutado
      if params[:event].nil?
        redirect_to(event_url(code: @event.ligilo),
          flash: {error: "Vi devas unue elekti dosieron"}) && return
      end

      if @event.uploads.attach(params[:event][:uploads])
        flash[:notice] = "Dokumento sukcese alŝutita"
      else
        flash[:error] = "Dosier-formato ne valida"
      end
      redirect_to event_path(code: @event.ligilo)
    elsif @event.update(event_params)
      EventoGhisdatigitaJob.perform_later(@event)
      EventMailer.nova_administranto(@event).deliver_later if @event.saved_change_to_user_id?
      @event.update_event_organizations(params[:organization_ids])
      set_event_format(@event)
      ahoy.track "Update event", event_url: @event.short_url
      Log.create(text: "Updated event #{@event.title}", user: @current_user, event_id: @event.id)
      redirect_to event_path(code: @event.ligilo), notice: "Evento sukcese ĝisdatigita"
    else
      render :edit
    end
  rescue ActionView::Template::Error => e
    Sentry.capture_exception(e)
    PaperTrail.request.disable_model(Event)
    @event.update(event_params)
    PaperTrail.request.enable_model(Event)
    redirect_to event_path(code: @event.ligilo), notice: "Evento sukcese ĝisdatigita"
  end

  def destroy
    unless user_is_owner_or_admin(@event)
      redirect_to(event_path(code: @event.ligilo),
        flash: {error: "Vi ne rajtas forigi ĝin"}) && return
    end

    # Ne vere forviŝas la eventon el la datumbazo, sed kaŝas ĝin
    @event.delete!
    ahoy.track "Deleted event", event_url: @event.short_url
    Log.create(text: "Deleted event #{@event.title}", user: @current_user, event_id: @event.id)
    redirect_to root_url, flash: {error: "Evento sukcese forigita"}
  end

  def nuligi
    e = Event.by_link(params[:event_code])
    e.update(cancelled: true, cancel_reason: params[:cancel_reason])
    ahoy.track "Cancelled event", event_url: e.short_url
    redirect_to event_url(code: params[:event_code])
  end

  def malnuligi
    e = Event.by_link(params[:event_code])
    e.update(cancelled: false, cancel_reason: nil)
    ahoy.track "Un-cancelled event", event_url: e.short_url
    redirect_to event_url(code: params[:event_code])
  end

  def nova_importado
  end

  def importi
    datumoj = Importilo.new(params[:url]).datumoj
    if datumoj # Signifas ke la importado sukcesi kolekti informojn kaj eraroj ne troviĝis
      evento = Event.new(datumoj)
      evento.user_id = current_user.id
      evento.specolisto = "Alia"
      evento.import_url = params[:url]
      evento.save!
      redirect_to event_url(code: evento.code)
    else
      # Eraro okazis
      redirect_to importi_url, flash: {error: "Importado malsukcesis"}
    end
  end

  def delete_file
    event = Event.by_code(params[:event_code])
    event.uploads.find(params[:file_id]).purge_later
    redirect_to event_path(code: event.ligilo), flash: {success: "Dosiero sukcese forigita"}
  end

  def by_continent
    # Se la "kontinento" estas Reta, montru la eventojn per Kalendara vido
    # Se estas aliaj kontinentoj, montru per Kartaro aŭ Map
    if params[:continent] == "reta" && cookies[:vidmaniero] != "kalendaro"
      cookies[:vidmaniero] = {value: "kalendaro", expires: 2.weeks, secure: true}
    elsif params[:continent] != "reta"
      unless cookies[:vidmaniero].in? %w[kartaro mapo]
        cookies[:vidmaniero] = {value: "kartaro", expires: 2.weeks, secure: true}
      end
    end

    if params[:continent] != params[:continent].normalized
      redirect_to events_by_continent_path(params[:continent].normalized) and return
    end

    @future_events = Event.by_continent(params[:continent]).venontaj
    @events = @events.includes(:organizations).by_continent(params[:continent])
    @countries = @events.count_by_country
    @today_events = @events.today.includes(:country)
    @events = @events.not_today.includes(:country)

    kreas_paghadon_por_karta_vidmaniero if cookies[:vidmaniero] == "kartaro"
  end

  def by_country
    redirect_to(root_path, flash: {error: "Lando ne ekzistas en la datumbazo"}) && return if @country.nil?

    unless cookies[:vidmaniero].in? %w[kartaro mapo]
      cookies[:vidmaniero] = {value: "kartaro", expires: 2.weeks, secure: true}
      redirect_to events_by_country_url(continent: @country.continent.normalized, country_name: @country.name.normalized)
    end

    @future_events = Event.includes(:country).by_country_id(@country.id).venontaj
    @cities = @events.by_country_id(@country.id).count_by_cities
    @today_events = @events.today.includes(:country).by_country_id(@country.id)
    @events = @events.not_today.includes(:country).by_country_id(@country.id)

    kreas_paghadon_por_karta_vidmaniero
  end

  # Listigas la eventoj laŭ urboj
  def by_city
    redirect_to root_url, flash: {error: "Lando ne ekzistas"} and return if @country.nil?

    unless cookies[:vidmaniero].in? %w[kartaro mapo]
      cookies[:vidmaniero] = {value: "kartaro", expires: 2.weeks, secure: true}
      redirect_to events_by_city_url(params[:continent], params[:country_name], params[:city_name])
    end

    @future_events = Event.by_city(params[:city_name]).venontaj
    @today_events = @events.today.includes(:country).by_city(params[:city_name])
    @events = @events.not_today.by_city(params[:city_name])

    kreas_paghadon_por_karta_vidmaniero
  end

  def by_username
    @uzanto = User.find_by(username: params[:username])
    redirect_to root_path, flash: {error: "Uzantnomo ne ekzistas"} and return if @uzanto.nil?

    @venontaj = Event.includes(:country).by_username(params[:username]).venontaj
    @interested_events = @uzanto.interested_events

    @pasintaj = Event.includes(:country).by_username(params[:username]).pasintaj
    @pagy, @pasintaj = pagy(@pasintaj)
  end

  def kontakti_organizanton
    unless params[:sekurfrazo].strip.downcase == "esperanto"
      ligilo = Event.by_code(params[:event_code]).ligilo
      redirect_to(
        event_url(code: ligilo),
        flash: {error: "Malĝusta kontraŭspama sekurvorto. Entajpu la nomon de la internacia lingvo."}
      ) && return
    end

    informoj = {name: params[:name], email: params[:email], message: params[:message]}
    EventMailer.kontakti_organizanton(params[:event_code], informoj).deliver_later
    redirect_to event_url(code: params[:event_code]), flash: {info: "Mesaĝo sendita"}
  end

  def kronologio
    @event = Event.by_link(params[:event_code])

    version_ids = (@event.versions + @event.enhavo.versions).map(&:id)
    @versions = PaperTrail::Version.where(id: version_ids).order(created_at: :desc)

    redirect_to root_path, flash: {error: "Evento ne ekzistas"} unless @event
  end

  private

  # La karta vidmaniero uzas paĝadon. La aliaj ne. Tial necesas krei la variablojn
  # +@kvanto_venontaj_eventoj+ kaj +@pagy+
  #
  def kreas_paghadon_por_karta_vidmaniero
    return unless cookies[:vidmaniero].in?(%w[kartoj kartaro])

    @kvanto_venontaj_eventoj = @events.count
    @pagy, @events = pagy(@events.not_today.includes(%i[country organizations]))
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.by_link(params[:code] || params[:event_code])
    redirect_to root_path, flash: {error: "Evento ne ekzistas"} if @event.nil?
  end

  def set_country
    @country = Country.by_name(params[:country_name])
  end

  def sanitize_params
    params.delete(:pagho) if params[:pagho].to_i < 1
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    if params[:event][:date_start].present? # TODO: Arrumar - por conta do envio de arquivos
      params[:event][:date_start] = merge_date_time(params[:event][:date_start], params[:time_start],
        params[:event][:time_zone])
      params[:event][:date_end] = merge_date_time(params[:event][:date_end], params[:time_end],
        params[:event][:time_zone])

      params[:event][:specolisto] = if params[:specolisto].present?
        params[:specolisto].keys.collect { |k, _v| k }.join(", ")
      else
        ""
      end
    end

    params[:event][:commit] = params[:commit]

    params.require(:event).permit(
      :title, :description, :enhavo, :site, :email, :date_start, :date_end, :time_zone, :international_calendar,
      :address, :city, :country_id, :online, :user_id, :specolisto, :short_url, uploads: []
    )
  end

  # Nur la permesataj uzantoj povas redakti, ĝisdatiĝi kaj foriĝi la eventon
  def authorize_user
    unless user_can_edit_event?(user: current_user, event: @event)
      redirect_to root_url, flash: {error: "Vi ne rajtas"}
    end
  end

  def validate_continent
    continent_names = Country.pluck(:continent).uniq

    if params[:continent].normalized.in? continent_names.map(&:normalized)
      @continent = Country.continent_name(params[:continent])
    else
      redirect_to root_url, flash: {notice: "Ne estas eventoj en tiu kontinento"}
    end
  end

  def merge_date_time(date, time, _time_zone)
    # DateTime.strptime("#{date} #{time}", '%d/%m/%Y %H:%M')
    # "#{date} #{time}".in_time_zone(time_zone)
    "#{date} #{time}"
  end

  def spam_detected
    redirect_to root_path
  end

  def dosier_alshutado
    params[:commit] == "Alŝuti"
  end

  # Redirect event with old links to the new ones
  def redirect_old_link
    redirection = EventRedirection.find_by(old_short_url: params[:code])
    return unless redirection

    redirection.increment!(:hits)
    redirect_to event_path(code: redirection.new_short_url), status: :moved_permanently
  end

  def set_event_format(event)
    format =
      if !event.online?
        "onsite"
      elsif event.online? && event.city == "Reta"
        "online"
      elsif event.online? && event.city != "Reta"
        "hybrid"
      end

    event.update_columns(format:)
  end
end
