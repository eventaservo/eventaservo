# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!

    def index
      @uzantoj = User.order(:name)
    end
  end
end
