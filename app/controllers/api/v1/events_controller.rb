# frozen_string_literal: true

module Api
  module V1
    class EventsController < ApiController
      before_action :validate_index_params, only: :index

      def index
        ahoy.track "API V1 List Events", kind: "api"

        @events = Event.includes(:country).includes(:user).includes(:organizations).order(:date_start)

        if params[:uuid].present?
          @events = @events.by_uuid(params[:uuid])
        else
          @events = @events.by_dates(from: validate_date(params[:komenca_dato]), to: validate_date(params[:fina_dato]))
          @events = @events.by_country_code(params[:landa_kodo]) if params[:landa_kodo].present?
          @events = @events.lau_organizo(params[:o]) if params[:o].present?
        end
      end

      private

      # necesaj params:
      #   komenca_date + fina_dato
      # aŭ
      #   uuid
      def validate_index_params
        if (params[:komenca_dato].blank? || params[:fina_dato].blank?) && params[:uuid].blank?
          render json: {eraro: "Mankas datoj aŭ eventa uuid"}, status: :bad_request and return
        end

        date_string = /\d{4}-\d{2}-\d{2}/
        return true if params[:uuid].present?
        render json: {eraro: "Data formato malĝustas"}, status: :bad_request and return unless params[:komenca_dato] =~ date_string && params[:fina_dato] =~ date_string
      end

      def validate_date(date)
        Date.strptime(date, "%Y-%m-%d")
      end
    end
  end
end
