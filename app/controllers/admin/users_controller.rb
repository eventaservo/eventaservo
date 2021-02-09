# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @users = User.includes([:events, :country]).order(:name)
    end

    def show
      @user = User.find_by(id: params[:id])
    end

    def update
      @user = User.find_by(id: params[:id])
      if @user.update(user_params)
        redirect_to events_by_username_path(@user.username), flash: { success: 'Sukceso'}
      else
        render :show, flash: { error: 'Eraro okazis' }
      end
    end

    private

    def user_params
      params.require(:user).permit(:city, :country_id)
    end
  end
end
