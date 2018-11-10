# frozen_string_literal: true

module Admin
  class CountriesController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @landoj = Country.all
    end
  end
end
