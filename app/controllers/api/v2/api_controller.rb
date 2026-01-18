# frozen_string_literal: true

module Api
  module V2
    class ApiController < ApplicationController
      skip_before_action :verify_authenticity_token

      before_action :validas_token

      # Handles requests to invalid API v2 endpoints.
      #
      # Returns a JSON response with error details and a link to the API documentation.
      # This catch-all action is triggered by the '*path' route when no other
      # API v2 route matches the request.
      #
      # @return [void] Renders JSON with :not_found status (404)
      #
      # @example Response body
      #   {
      #     "error": "Endpoint not found",
      #     "documentation": "https://api.eventaservo.org"
      #   }
      def not_found
        render json: {
          error: "Endpoint not found",
          documentation: "https://api.eventaservo.org"
        }, status: :not_found
      end

      private

      def validas_token
        token = request.headers["Authorization"]&.gsub(/^Bearer /, "") || params["user_token"]

        if token.nil?
          ahoy.track "Token missing", kind: "api"
          render json: {eraro: I18n.t("api.v2.errors.token_missing")}, status: :unauthorized and return
        end

        begin
          decoded = ::JWT.decode token, Rails.application.credentials.dig(:jwt, :secret)
        rescue JWT::DecodeError
          ahoy.track "Token invalid", kind: "api"
          render json: {eraro: I18n.t("api.v2.errors.token_invalid")}, status: :unauthorized and return
        end

        @user = ::User.find(decoded[0]["id"])

        if @user.jwt_token != token
          ahoy.track "Token expired/regenerated", kind: "api"
          render json: {eraro: I18n.t("api.v2.errors.token_expired")}, status: :unauthorized and return
        end
      end
    end
  end
end
