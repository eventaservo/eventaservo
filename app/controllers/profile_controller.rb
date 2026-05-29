class ProfileController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[events]

  def events
    @interested_events = @user.interested_events
    @future_events = Event.includes(:country).by_username(params[:username]).venontaj
    @past_events = Event.includes(:country).by_username(params[:username]).pasintaj
    @pagy, @past_events = pagy(@past_events)
  end

  private

  def set_user
    @user = User.find_by(username: params[:username])

    redirect_to root_path, flash: {error: "Uzanto ne trovita"} and return unless @user

    if @current_user != @user
      redirect_to root_path, flash: {error: "Vi ne rajtas vidi tiun paĝon"}
    end
  end
end
