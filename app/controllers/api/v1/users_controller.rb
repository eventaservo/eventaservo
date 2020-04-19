# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      def rekrei_api_kodon
        if params[:id].to_i == current_user.id
          User.find(params[:id]).update(authentication_token: Devise.friendly_token)
          redirect_to edit_user_registration_path
        else
          redirect_to root_url, flash: { error: 'Vi ne rajtas fari tion.' }
        end
      end
    end
  end
end
