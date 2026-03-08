# frozen_string_literal: true

module Admin
  # Admin controller for managing events.
  #
  # Provides listing, soft-delete recovery, and filtering of events
  # for administrative purposes.
  class EventsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    # Displays all events with pagination and optional filters.
    #
    # @return [void]
    def index
      @countries = Country.all
      @organizations = Organization.all.order(:name)
      @forigitaj = params[:forigitaj] == "1"

      events = if @forigitaj
        Event.deleted.includes(:user, :country, :organizations).order(date_start: :desc)
      else
        Event.includes(:user, :country, :organizations).order(date_start: :desc)
      end
      events = apply_filters(events)

      @pagy, @events = pagy(events)
    end

    # Recovers a soft-deleted event by its code.
    #
    # @return [void]
    def recover
      event = Event.deleted.find_by(code: params[:event_code])
      event.undelete!
      redirect_to admin_events_path(forigitaj: "1"), flash: {success: "Evento sukcese restaŭrita"}
    end

    private

    # Applies filter params to the events query.
    #
    # @param events [ActiveRecord::Relation] the base events relation
    # @return [ActiveRecord::Relation] the filtered events relation
    def apply_filters(events)
      events = events.where("date_start >= ?", params[:start_date]) if params[:start_date].present?
      events = events.where("date_start <= ?", params[:end_date]) if params[:end_date].present?
      events = events.where("title ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(params[:title])}%") if params[:title].present?
      events = events.where(country_id: params[:country_id]) if params[:country_id].present?
      if params[:organization_id].present?
        events = events.joins(:organization_events).where(organization_events: {organization_id: params[:organization_id]})
      end
      events = events.without_location if params[:senlokaj] == "1"
      events
    end
  end
end
