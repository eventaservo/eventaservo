# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @users = User.includes(:events).order(:name)
    end

    def show
      @user = User.includes(:events).find_by(id: params[:id])
    end
  end
end
