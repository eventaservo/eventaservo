# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @users = User.includes([:country]).order(:name)
      @total_users = @users.count
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

    def kunigi
      old_user_id = params[:user_id]
      new_user_id = params[:id]

      if User.find(old_user_id).merge_to(new_user_id)
        redirect_to admin_users_path, flash: { success: 'Uzant-kontoj sukcese kunigitaj' }
      else
        redirect_to admin_users_path, flash: { error: 'Eraro okazis. Ne eblis kunigi kontojn' }
      end
    end

    private

    def user_params
      params.require(:user).permit(:city, :country_id)
    end
  end
end
