# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  include Devise::Controllers::Rememberable

  after_action :remember_logged_in_user, only: :create

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    params[:user][:remember_me] = 1 # Ĉiam memoras la uzanton
    super
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  #

  private

    def remember_logged_in_user
      remember_me(self.resource)
    end
end
