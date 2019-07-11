# frozen_string_literal: true

module Admin
  class AnalizadoController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
    end
  end
end
