# frozen_string_literal: true

module Webcal
  class WebcalController < ApplicationController
    before_action :definas_landon, only: :lando

    def lando
      eventoj = Event.lau_lando(@lando).for_webcal

      respond_to do |format|
        format.ics do
          cal              = Icalendar::Calendar.new
          cal.x_wr_calname = "#{@lando.code.upcase} Esperantaj eventoj"
          eventoj.includes(:country).each { |evento| kreas_webcal_eventon(cal, evento) }
          cal.publish
          render plain: cal.to_ical
        end
      end
    end

    private

      def definas_landon
        redirect_to root_url if params[:landa_kodo].blank?

        @lando = Country.find_by(code: params[:landa_kodo])
        redirect_to root_url, flash: { notice: 'Landa kodo ne ekzistas' } if @lando.nil?
      end

      def kreas_webcal_eventon(icalendar, evento)
        icalendar.event do |e|
          e.dtstart = Icalendar::Values::DateOrDateTime.new(evento.date_start.strftime('%Y%m%d')).call
          e.dtend   = if evento.date_end > evento.date_start
                        Icalendar::Values::DateOrDateTime.new((evento.date_end + 1.day).strftime('%Y%m%d')).call
                      else
                        Icalendar::Values::DateOrDateTime.new(evento.date_end.strftime('%Y%m%d')).call
                      end

          e.summary     = evento.title
          e.description = evento.description + '\n\n' + event_url(evento.code)
          e.location    = evento.full_address
        end
      end
  end
end
