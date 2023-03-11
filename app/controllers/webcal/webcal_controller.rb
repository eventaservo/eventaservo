# frozen_string_literal: true

module Webcal
  class WebcalController < ApplicationController
    include Webcal
    before_action :definas_landon, only: :lando

    def lando
      eventoj = if @lando.code == "ol" # Retaj eventoj
        Event.ne_nuligitaj.ne_anoncoj.venontaj.online
      else
        Event.ne_nuligitaj.ne_anoncoj.lau_lando(@lando).for_webcal
      end

      respond_to do |format|
        format.ics { kreas_webcal(eventoj.includes(:country), title: "#{@lando.code.upcase} Esperantaj eventoj") }
      end
    end

    # Produktas la .ics webcal-versio de eventoj de la organizo
    # Ricevas la organizan mallongan nomon per
    #   params[:short_name]
    #
    def organizo
      redirect_to root_url if params[:short_name].blank?

      o = Organization.find_by(short_name: params[:short_name])
      redirect_to root_url, flash: {error: "Organizo ne ekzistas"} and return if o.nil?

      eventoj = Event.lau_organizo(o.short_name).for_webcal

      respond_to do |format|
        format.ics { kreas_webcal(eventoj, title: "#{o.short_name} Esperantaj eventoj") }
      end
    end

    # Generates the user's calendar
    #
    # @return [ICS file]
    def user
      user = User.find_by(webcal_token: params[:webcal_token])
      redirect_to root_url, flash: {error: "Uzanto ne ekzisstas"} and return if user.nil?

      events = (user.events.includes([:country]) + user.interested_events.includes([:country])).uniq

      ahoy = Ahoy::Tracker.new(controller: self, user: user)
      ahoy.track "Personal calendar"

      respond_to do |format|
        format.ics { kreas_webcal(events, title: "Eventa Servo persona") }
      end
    end

    private

    def definas_landon
      redirect_to root_url if params[:landa_kodo].blank?

      @lando = Country.find_by(code: params[:landa_kodo])
      redirect_to root_url, flash: {notice: "Landa kodo ne ekzistas"} if @lando.nil?
    end
  end
end
