# frozen_string_literal: true

# Controller managing user-specific personal event pages.
class ProfileController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[events]

  # Displays the authenticated user's interested and organized events.
  #
  # @return [void]
  def events
    @interested_events = @user.interested_events
    @future_events = Event.includes(:country).by_username(params[:username]).venontaj
    @past_events = Event.includes(:country).by_username(params[:username]).pasintaj
    @pagy, @past_events = pagy(@past_events)
  end

  private

  # Finds the user by username parameter or redirects.
  #
  # @return [void]
  def set_user
    @user = User.find_by(username: params[:username])

    redirect_to root_path, flash: {error: I18n.t("flash.users.not_found")} and return unless @user

    if @current_user != @user
      redirect_to root_path, flash: {error: I18n.t("flash.general.unauthorized_action")}
    end
  end
end
