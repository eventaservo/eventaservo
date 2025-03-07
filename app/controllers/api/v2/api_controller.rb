# frozen_string_literal: true

module Api
  module V2
    class ApiController < ApplicationController
      skip_before_action :verify_authenticity_token

      before_action :validas_token

      private

      def validas_token
        token = request.headers["Authorization"]&.gsub(/^Bearer /, "")

        if token.nil?
          ahoy.track "Token missing", kind: "api"
          render json: {eraro: "Token mankas"}, status: :unauthorized and return
        end

        begin
          decoded = ::JWT.decode token, Rails.application.credentials.dig(:jwt, :secret)
        rescue JWT::DecodeError
          ahoy.track "Token invalid", kind: "api"
          render json: {eraro: "Token ne validas"}, status: :unauthorized and return
        end

        @user = ::User.find(decoded[0]["id"])
      end
    end
  end
end
