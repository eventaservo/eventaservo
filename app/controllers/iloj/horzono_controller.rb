# frozen_string_literal: true
module Iloj
  class HorzonoController < ApplicationController
    def elektas
      cookies[:horzono] = {
        value: params[:horzono], expires: 1.year, secure: true
      }
      redirect_to request.referrer,
                  flash: { success: 'Horzono elektita sukcese' }
    end

    def forvishas
      cookies.delete :horzono

      if request.referrer
        redirect_to request.referrer,
                    flash: { success: 'Horzona informo forviŝita sukcese' }
      else
        redirect_to root_url
      end
    end
  end
end
