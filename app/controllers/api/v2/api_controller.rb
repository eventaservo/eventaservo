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

      # Authenticates the incoming API v2 request using a JWT Bearer token or
      # +user_token+ query parameter.
      #
      # Rejects missing, invalid, expired, disabled, or unconfirmed accounts,
      # and sets +PaperTrail.request.whodunnit+ for auditing.
      #
      # @return [void]
      def validas_token
        token = extract_auth_token

        if token.blank?
          ahoy.track "Token missing", kind: "api"
          render_auth_error(:token_missing, status: :unauthorized) and return
        end

        decoded = decode_token(token)
        if decoded.nil?
          ahoy.track "Token invalid", kind: "api"
          render_auth_error(:token_invalid, status: :unauthorized) and return
        end

        @user = ::User.unscoped.find_by(id: decoded[0]["id"])

        if @user.nil?
          ahoy.track "Token invalid", kind: "api"
          render_auth_error(:token_invalid, status: :unauthorized) and return
        end

        if @user.jwt_token != token
          ahoy.track "Token expired/regenerated", kind: "api"
          render_auth_error(:token_expired, status: :unauthorized) and return
        end

        if @user.disabled? || !@user.confirmed?
          ahoy.track "Account inactive", kind: "api"
          render_auth_error(:account_inactive, status: :forbidden) and return
        end

        PaperTrail.request.whodunnit = @user.id.to_s
      end

      # Decodes a HS256 JWT token, returning nil when decoding fails.
      #
      # @param token [String] raw JWT string
      #
      # @return [Array, nil] decoded JWT payload and header, or nil on error
      def decode_token(token)
        ::JWT.decode(token, Rails.application.credentials.dig(:jwt, :secret), true, algorithm: "HS256")
      rescue JWT::DecodeError
        nil
      end

      # Returns the authenticated API user's ID for PaperTrail auditing.
      #
      # @return [String, nil]
      def user_for_paper_trail
        @user&.id&.to_s
      end

      # Extracts the JWT token from the Authorization header or +user_token+ param.
      #
      # @return [String, nil] the raw JWT string, if present
      def extract_auth_token
        request.headers["Authorization"]&.gsub(/^Bearer /, "") || params["user_token"]
      end

      # Renders an authentication error in the legacy Esperanto format.
      #
      # English-contract controllers override this method to return `{ error: ... }`.
      #
      # @param error_key [Symbol] error identifier (+:token_missing+, +:token_invalid+, +:token_expired+, +:account_inactive+)
      # @param status [Symbol] HTTP status symbol
      #
      # @return [void]
      def render_auth_error(error_key, status:)
        message = case error_key
        when :token_missing
          I18n.t("api.v2.errors.token_missing")
        when :token_invalid
          I18n.t("api.v2.errors.token_invalid")
        when :token_expired
          I18n.t("api.v2.errors.token_expired")
        when :account_inactive
          "Account is disabled or unconfirmed"
        end

        render json: {eraro: message}, status:
      end
    end
  end
end
