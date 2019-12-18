# frozen_string_literal: true
module Iloj

  class MallongiloController < ApplicationController

    # Kontrolas ĉu la mallongilo estas disponeblas
    # Ricevas:
    #   params:
    #     kodo,
    #     mallongilo
    #
    # @return [Boolean]
    def disponeblas
      disponeblo = true if params[:kodo] == params[:mallongilo]
      disponeblo = true if params[:mallongilo].empty?

      disponeblo = Event.lau_ligilo(params[:mallongilo]).nil?
      render json: { disponeblo: disponeblo }
    end
  end
end
