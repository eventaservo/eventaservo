# frozen_string_literal: true

module Iloj
  class MallongiloController < ApplicationController
    # Checks whether a short URL is still available for an event.
    #
    # A missing or blank +mallongilo+ param is treated as available, so the
    # check also works when the request arrives without parameters (e.g. from
    # a crawler directly hitting the endpoint).
    #
    # @return [void]
    def disponeblas
      params[:id] = 1 if params[:id].blank? # Trick to always have an event ID to check against, even when creating a new event

      @short_url_available =
        params[:mallongilo].blank? ||
        (Event.where("LOWER(short_url) = ?", params[:mallongilo].downcase).where.not(id: params[:id]).empty? &&
        EventRedirection.where("LOWER(old_short_url) = ?", params[:mallongilo].downcase).empty?)

      respond_to do |format|
        format.turbo_stream
      end
    end
  end
end
