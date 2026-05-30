# frozen_string_literal: true

class EventsController < ApplicationController
  rescue_from ActionController::UnknownFormat do |_e|
    redirect_to root_url, flash: {error: "Formato ne ekzistas."}
  end
  include Webcal

  before_action :authenticate_user!, only: %i[index new create edit update destroy kontakti_organizanton nuligi malnuligi delete_file]
  before_action :redirect_old_link, only: %i[show edit]
  before_action :set_event, only: %i[show edit update destroy kronologio nuligi malnuligi kontakti_organizanton delete_file]
  before_action :authorize_user, only: %i[edit update destroy nuligi malnuligi delete_file]

  # Montras la uzantajn eventojn
  # This action is probable deprecated and it is required to explore if can be removed
  def index
    @events = Event.includes(:country).by_user(current_user).order(date_start: :desc)
  end

  def show
    # ahoy.track "Show event", event_url: @event.short_url

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
      @event.tag_ids = origin.tag_ids
      @copied_tags = Tag.where(id: origin.tag_ids)
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
    mark_dates_from_form

    if @event.save
      # Process categories tags
      if params[:tags_categories].present?
        params[:tags_categories].each do |id|
          tag = Tag.find(id)
          @event.tags << tag unless @event.tags.include?(tag)
        end
      end

      # Process characteristics tags
      if params[:tags_characteristics].present?
        params[:tags_characteristics].each do |id|
          tag = Tag.find(id)
          @event.tags << tag unless @event.tags.include?(tag)
        end
      end

      @event.update_event_organizations(params[:organization_ids])
      set_event_format(@event)
      NovaEventaSciigoJob.perform_later(@event)
      ahoy.track "Create event", event_url: @event.short_url
      Logs::Create.call(text: "Event created", user: current_user, loggable: @event)
      redirect_to event_path(code: @event.ligilo), flash: {notice: "Evento sukcese kreita."}
    else
      render :new
    end
  end

  def update # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    mark_dates_from_form

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
      # Process categories tags
      if params[:tags_categories].present?
        @event.tags.categories.where.not(id: params[:tags_categories]).each do |tag|
          @event.tags.delete(tag)
        end
        params[:tags_categories].each do |id|
          tag = Tag.find(id)
          @event.tags << tag unless @event.tags.include?(tag)
        end
      else
        # Remove all category tags if no categories are selected
        @event.tags.categories.each { |tag| @event.tags.delete(tag) }
      end

      # Process characteristics tags
      if params[:tags_characteristics].present?
        @event.tags.characteristics.where.not(id: params[:tags_characteristics]).each do |tag|
          @event.tags.delete(tag)
        end
        params[:tags_characteristics].each do |id|
          tag = Tag.find(id)
          @event.tags << tag unless @event.tags.include?(tag)
        end
      else
        @event.tags.characteristics.each { |tag| @event.tags.delete(tag) }
      end

      EventoGhisdatigitaJob.perform_later(@event)
      EventMailer.nova_administranto(@event).deliver_later if @event.saved_change_to_user_id?
      @event.update_event_organizations(params[:organization_ids])
      set_event_format(@event)
      ahoy.track "Update event", event_url: @event.short_url
      Logs::Create.call(text: "Event updated", user: current_user, loggable: @event)
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
    result = Events::SoftDelete.call(event: @event, user: current_user)

    if result.success?
      redirect_to root_url, flash: {notice: "Evento sukcese forigita"}
    else
      redirect_to event_path(code: @event.ligilo), flash: {error: result.error}
    end
  end

  def nuligi
    @event.update(cancelled: true, cancel_reason: params[:cancel_reason])
    ahoy.track "Cancelled event", event_url: @event.short_url

    redirect_to event_url(code: params[:event_code]), flash: {notice: "Evento nuligita"}
  end

  def malnuligi
    @event.update(cancelled: false, cancel_reason: nil)
    ahoy.track "Un-cancelled event", event_url: @event.short_url

    redirect_to event_url(code: params[:event_code]), flash: {notice: "Evento malnuligita"}
  end

  def delete_file
    @event.uploads.find(params[:file_id]).purge_later
    redirect_to event_path(code: @event.ligilo), flash: {success: "Dosiero sukcese forigita"}
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
    message = params[:message]

    EventMailer.kontakti_organizanton(event: @event, user: current_user, message:).deliver_later

    redirect_to event_url(code: params[:event_code]), flash: {info: "Mesaĝo sendita"}
  end

  def kronologio
    # Cache key based on event and last version update
    cache_key = "kronologio_#{@event.id}_#{@event.updated_at.to_i}"

    # Try to get from cache first
    cached_data = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      build_kronologio_data(@event)
    end

    # Apply pagination to cached data
    @pagy, @versions = pagy(cached_data[:versions], limit: 15)
    @users_cache = cached_data[:users_cache]
    @countries_cache = cached_data[:countries_cache]
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.by_link(params[:code] || params[:event_code])
    redirect_to root_path, flash: {error: "Evento ne ekzistas"} if @event.nil?
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

  def merge_date_time(date, time, _time_zone)
    # DateTime.strptime("#{date} #{time}", '%d/%m/%Y %H:%M')
    # "#{date} #{time}".in_time_zone(time_zone)
    "#{date} #{time}"
  end

  # Marks the event so the model reinterprets its wall-clock date components
  # in the event's time zone during save. Only flips on when the form
  # submitted +time_start+, which is the signal that the user typed a
  # wall-clock value the model must preserve.
  #
  # @return [void]
  def mark_dates_from_form
    @event.dates_from_form = true if params[:time_start].present?
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

  def build_kronologio_data(event)
    # Single optimized query to get all versions
    versions = PaperTrail::Version
      .joins("LEFT JOIN users ON versions.whodunnit = users.id::text")
      .where(build_versions_where_clause(event))
      .select("versions.*, users.name as user_name")
      .order(created_at: :desc)
      .limit(500) # Reasonable limit for performance

    # Preload users and countries that might be referenced in changesets
    all_user_ids = Set.new
    all_country_ids = Set.new

    versions.each do |version|
      version.changeset.each do |_field, changes|
        if changes.is_a?(Array) && changes.length == 2
          all_user_ids << changes[0].to_i if changes[0].to_s.match?(/^\d+$/)
          all_user_ids << changes[1].to_i if changes[1].to_s.match?(/^\d+$/)
          all_country_ids << changes[0].to_i if changes[0].to_s.match?(/^\d+$/)
          all_country_ids << changes[1].to_i if changes[1].to_s.match?(/^\d+$/)
        end
      end
    end

    users_cache = User.where(id: all_user_ids.to_a).index_by(&:id)
    countries_cache = Country.where(id: all_country_ids.to_a).index_by(&:id)

    {
      versions: versions.to_a,
      users_cache: users_cache,
      countries_cache: countries_cache
    }
  end

  def build_versions_where_clause(event)
    event_clause = "(item_type = 'Event' AND item_id = #{event.id})"

    # Handle rich text versions for enhavo
    rich_text_clause = if event.enhavo.present?
      rich_text_id = event.enhavo.id
      "(item_type = 'ActionText::RichText' AND item_id = #{rich_text_id})"
    else
      "(1=0)" # No enhavo versions
    end

    "#{event_clause} OR #{rich_text_clause}"
  end
end
