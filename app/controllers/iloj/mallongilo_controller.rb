# frozen_string_literal: true

module Iloj
  class MallongiloController < ApplicationController
    # Kontrolas ĉu la mallongilo estas disponeblas
    # Ricevas:
    #   params:
    #     id,
    #     mallongilo
    #
    # @return [Boolean]
    def disponeblas
      @short_url_available =
        params[:mallongilo].empty? ||
        Event.where("LOWER(short_url) = ?", params[:mallongilo].downcase).where.not(id: params[:id]).empty?

      respond_to do |format|
        format.turbo_stream
      end
    end
  end
end
