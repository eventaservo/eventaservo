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
      params[:id] = 1 if params[:id].blank? # Trick to always have an event ID to check against, even when creating a new event

      @short_url_available =
        params[:mallongilo].empty? ||
        (Event.where("LOWER(short_url) = ?", params[:mallongilo].downcase).where.not(id: params[:id]).empty? &&
        EventRedirection.where("LOWER(old_short_url) = ?", params[:mallongilo].downcase).empty?)

      respond_to do |format|
        format.turbo_stream
      end
    end
  end
end
