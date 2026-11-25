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

      filter_params = params.permit(:forigitaj, :start_date, :end_date, :title, :country_id, :organization_id, :senlokaj)
      @pagy, @events = pagy(::Events::AdminSearchQuery.new(filter_params).call)
    end

    # Recovers a soft-deleted event by its code.
    #
    # @return [void]
    def recover
      event = Event.deleted.find_by(code: params[:event_code])
      event.undelete!
      redirect_to admin_events_path(forigitaj: "1"), flash: {success: "Evento sukcese restaŭrita"}
    end
  end
end
