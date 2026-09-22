# frozen_string_literal: true

module Users
  # Persists the teaching profile from the account-update form.
  #
  # When the user opts in as a teacher (the `instruisto` checkbox is "true"),
  # stores the chosen levels and teaching experience into the `instruo` JSONB
  # column. Otherwise removes any previously stored teaching information.
  #
  # @example
  #   Users::SaveTeachingInfo.call(user: current_user, params: params)
  #
  class SaveTeachingInfo < ApplicationService
    attr_reader :user, :params

    # @param user [User] the user whose teaching info is updated
    # @param params [ActionController::Parameters] the account-update form params
    def initialize(user:, params:)
      @user = user
      @params = params
    end

    # Stores or clears the user's teaching profile and persists the change.
    #
    # @return [ApplicationService::Response] success with the user payload, or failure when saving fails
    def call
      update_teaching_info

      if user.save
        success(user)
      else
        failure("Failed to save teaching info")
      end
    end

    private

    # Applies the teaching profile changes in memory based on the form params.
    #
    # @return [void]
    def update_teaching_info
      if params[:user][:instruisto] == "true"
        user.instruisto = true
        user.instruo["nivelo"] = params[:nivelo].present? ? params[:nivelo].keys : ["baza"]
        user.instruo["sperto"] = params[:instru_sperto]
      else
        user.instruo.delete("instruisto")
        user.instruo.delete("nivelo")
        user.instruo.delete("sperto")
      end
    end
  end
end
