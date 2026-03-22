# frozen_string_literal: true

# Controller for managing event recurrence rules.
#
# Allows event owners and admins to create, edit, and destroy
# recurrence patterns on events.
class EventRecurrencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :authorize_user
  before_action :set_recurrence, only: %i[edit update destroy]

  # Renders the new recurrence form.
  #
  # @return [void]
  def new
    if @event.recurring_master?
      redirect_to event_path(code: @event.ligilo), flash: {error: t("recurrences.already_exists")}
      return
    end

    @recurrence = EventRecurrence.new
  end

  # Creates a recurrence rule and generates initial child events.
  #
  # @return [void]
  def create
    result = EventRecurrences::Create.call(
      event: @event,
      recurrence_params: recurrence_params
    )

    if result.success?
      redirect_to event_path(code: @event.ligilo), flash: {success: t("recurrences.created")}
    else
      @recurrence = EventRecurrence.new(recurrence_params)
      flash.now[:error] = result.error
      render :new, status: :unprocessable_entity
    end
  end

  # Renders the edit recurrence form.
  #
  # @return [void]
  def edit
    redirect_to event_path(code: @event.ligilo), flash: {error: t("recurrences.inactive")} unless @recurrence.active?
  end

  # Updates the recurrence rule and optionally propagates changes.
  #
  # @return [void]
  def update
    unless @recurrence.active?
      redirect_to event_path(code: @event.ligilo), flash: {error: t("recurrences.inactive")}
      return
    end
    result = EventRecurrences::Update.call(
      recurrence: @recurrence,
      recurrence_params: recurrence_params
    )

    if result.success?
      redirect_to event_path(code: @event.ligilo), flash: {success: t("recurrences.updated")}
    else
      flash.now[:error] = result.error
      render :edit, status: :unprocessable_entity
    end
  end

  # Destroys the recurrence rule and optionally deletes future events.
  #
  # @return [void]
  def destroy
    result = EventRecurrences::Destroy.call(
      recurrence: @recurrence,
      delete_future_events: params[:delete_future_events] == "1"
    )

    if result.success?
      redirect_to event_path(code: @event.ligilo), flash: {success: t("recurrences.destroyed")}
    else
      redirect_to event_path(code: @event.ligilo), flash: {error: result.error}
    end
  end

  private

  # @return [void]
  def set_event
    @event = Event.by_link(params[:event_code])
    redirect_to root_path, flash: {error: "Evento ne ekzistas"} unless @event
  end

  # @return [void]
  def authorize_user
    unless user_can_edit_event?(user: current_user, event: @event)
      redirect_to root_url, flash: {error: "Vi ne rajtas"}
    end
  end

  # @return [void]
  def set_recurrence
    @recurrence = @event.recurrence
    redirect_to event_path(code: @event.ligilo), flash: {error: t("recurrences.not_found")} unless @recurrence
  end

  # @return [ActionController::Parameters]
  def recurrence_params
    params.require(:event_recurrence).permit(
      :frequency, :interval, :day_of_month, :week_of_month,
      :day_of_week_monthly, :month_of_year, :end_type, :end_date,
      days_of_week: []
    ).tap do |p|
      p[:days_of_week] = p[:days_of_week]&.map(&:to_i) if p[:days_of_week].present?
    end
  end
end
