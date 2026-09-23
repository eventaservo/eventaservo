# frozen_string_literal: true

module Users
  # Persists the speaking profile from the account-update form.
  #
  # When the user opts in as a speaker (the `preleganto` checkbox is "true"),
  # stores the chosen topics into the `prelego` JSONB column. Otherwise removes
  # any previously stored speaking information.
  #
  # @example
  #   Users::SaveSpeakingInfo.call(user: current_user, params: params)
  #
  class SaveSpeakingInfo < ApplicationService
    attr_reader :user, :params

    # @param user [User] the user whose speaking info is updated
    # @param params [ActionController::Parameters] the account-update form params
    def initialize(user:, params:)
      @user = user
      @params = params
    end

    # Stores or clears the user's speaking profile and persists the change.
    #
    # @return [ApplicationService::Response] success with the user payload, or failure when saving fails
    def call
      update_speaking_info

      if user.save
        success(user)
      else
        failure("Failed to save speaking info")
      end
    end

    private

    # Applies the speaking profile changes in memory based on the form params.
    #
    # @return [void]
    def update_speaking_info
      if params[:user][:preleganto] == "true"
        user.preleganto = true
        user.prelego["temoj"] = params[:preleg_temoj]
      else
        user.prelego.delete("preleganto")
        user.prelego.delete("temoj")
      end
    end
  end
end
