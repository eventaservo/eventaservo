# frozen_string_literal: true

module Users
  # Service to regenerate the API V2 JWT token for a user.
  # This service invalidates the old token and generates a new one.
  #
  # @example
  #   Users::RegenerateApiToken.call(user: current_user)
  #
  class RegenerateApiToken < ApplicationService
    attr_reader :user

    # @param user [User] The user for whom to regenerate the token
    def initialize(user:)
      @user = user
    end

    # Executes the token regeneration.
    #
    # @return [ApplicationService::Response] Success with user payload or failure with error message
    def call
      payload = {
        id: user.id, 
        iat: Time.now.to_i,
        jti: SecureRandom.uuid
      }
      jwt_token = JWT.encode(payload, Rails.application.credentials.dig(:jwt, :secret), "HS256")
      
      user.jwt_token = jwt_token
      user.save!

      success(user)
    rescue StandardError => e
      failure(e.message)
    end
  end
end
