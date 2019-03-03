# frozen_string_literal: true

module Api
  module V1
    class EventsController < ApiController
      before_action :validate_index_params, only: :index

      def index
        @events = Event.includes(:country).includes(:user)

        if params[:uuid].present?
          @events = @events.by_uuid(params[:uuid])
        else
          @events = @events.by_dates(from: validate_date(params[:komenca_dato]), to: validate_date(params[:fina_dato]))
          @events = @events.by_country_code(params[:landa_kodo]) if params[:landa_kodo].present?
        end
      end

      private

        # necesaj params:
        #   komenca_date + fina_dato
        # aŭ
        #   uuid
        def validate_index_params
          if (params[:komenca_dato].blank? || params[:fina_dato].blank?) && params[:uuid].blank?
            render json: { eraro: 'Mankas datoj aŭ eventa uuid' }
          end
        end

        def validate_date(date)
          Date.strptime(date, '%Y-%m-%d')
        rescue ArgumentError
          render json: { eraro: 'Data formato malĝustas' }
        end
    end
  end
end
