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

      events = Event.includes(:user, :country, :organizations).order(date_start: :desc)
      events = apply_filters(events)

      @pagy, @events = pagy(events)
    end

    # Displays soft-deleted events.
    #
    # @return [void]
    def deleted
      @events = Event.deleted
    end

    # Recovers a soft-deleted event by its code.
    #
    # @return [void]
    def recover
      event = Event.deleted.find_by(code: params[:event_code])
      event.undelete!
      redirect_to event_path(code: event.ligilo), flash: {success: "Evento sukcesi restaŭrata"}
    end

    # Displays events that have no location set.
    #
    # @return [void]
    def senlokaj_eventoj
      @events = Event.without_location
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
      events
    end
  end
end
