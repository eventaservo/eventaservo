# frozen_string_literal: true

module Iloj
  # Lets the visitor pick or clear the timezone stored in the `horzono`
  # cookie used across the app to render local event times.
  class HorzonoController < ApplicationController
    # Validates and stores the selected timezone in the `horzono` cookie.
    # Legacy IANA identifiers are rewritten to their canonical form via
    # {TimeZone::Normalize}; blank or unresolvable values are rejected.
    #
    # @return [void]
    def elektas
      raw = params[:horzono]
      result = TimeZone::Normalize.call(raw)

      if raw.blank? || result.failure?
        redirect_to(request.referrer || root_url,
          flash: {error: "Nevalida horzono"})
        return
      end

      cookies[:horzono] = {
        value: result.payload, expires: 1.year, secure: true
      }
      redirect_to request.referrer,
        flash: {success: "Horzono elektita sukcese"}
    end

    # Removes the `horzono` cookie, reverting the visitor to default
    # timezone handling (the event's own `time_zone`).
    #
    # @return [void]
    def forvishas
      cookies.delete :horzono

      if request.referrer
        redirect_to request.referrer,
          flash: {success: "Horzona informo forviŝita sukcese"}
      else
        redirect_to root_url
      end
    end
  end
end
