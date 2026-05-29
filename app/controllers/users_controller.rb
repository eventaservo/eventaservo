# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  # POST /users/regenerate_api_token
  def regenerate_api_token
    Rails.logger.info "========== REGENERATE API TOKEN CALLED =========="
    result = Users::RegenerateApiToken.call(user: current_user)

    if result.success?
      Logs::Create.call(
        text: "User regenerated API token",
        user: current_user,
        loggable: current_user
      )
      flash[:notice] = I18n.t("activerecord.registrations.token_regenerated")
    else
      flash[:error] = I18n.t("activerecord.registrations.token_regeneration_error", error: result.error)
    end

    redirect_back fallback_location: edit_user_registration_path, status: :see_other
  end
end
