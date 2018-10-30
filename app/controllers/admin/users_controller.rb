# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @users = User.order(:name)
    end

    def show
      @user = User.find(params[:id])
    end
  end
end
