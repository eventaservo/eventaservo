# frozen_string_literal: true

module Admin
  # Admin controller for managing event recurrence rules.
  #
  # Provides listing, detail view, and active/inactive toggle
  # for all recurrence rules in the system.
  class EventRecurrencesController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!
    before_action :set_recurrence, only: %i[show deactivate reactivate]

    # Lists all event recurrences with pagination and filters.
    #
    # @return [void]
    def index
      recurrences = EventRecurrence.joins(:master_event).includes(master_event: :country).order(created_at: :desc)
      recurrences = recurrences.where(active: params[:active] == "1") if params[:active].present?
      recurrences = recurrences.where(frequency: params[:frequency]) if params[:frequency].present?

      @pagy, @recurrences = pagy(recurrences)
    end

    # Shows recurrence details and all related events (master + children).
    #
    # @return [void]
    def show
      @presenter = EventRecurrencePresenter.new(recurrence: @recurrence)
      master = @recurrence.master_event

      # All events in the series: master + children, ordered by date
      all_events = Event.unscoped
        .where("id = :master_id OR recurrent_master_event_id = :master_id", master_id: master.id)
        .includes(:country)
        .order(:date_start)

      @pagy, @series_events = pagy(all_events, limit: 25)
    end

    # Deactivates a recurrence rule.
    #
    # @return [void]
    def deactivate
      @recurrence.deactivate!
      redirect_to admin_event_recurrence_path(@recurrence),
        flash: {success: "Recurrence deactivated"}
    end

    # Reactivates a recurrence rule.
    #
    # @return [void]
    def reactivate
      @recurrence.reactivate!
      redirect_to admin_event_recurrence_path(@recurrence),
        flash: {success: "Recurrence reactivated"}
    end

    private

    # @return [void]
    def set_recurrence
      @recurrence = EventRecurrence.joins(:master_event).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_event_recurrences_path, flash: {error: "Recurrence not found or master event was deleted"}
    end
  end
end
