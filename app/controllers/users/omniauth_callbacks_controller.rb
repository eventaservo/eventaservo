# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable

  def facebook
    @user = User.from_omniauth(request.env["omniauth.auth"])
    remember_me(@user)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def google_oauth2
    return unless auth

    user = get_user_from_email(auth.info.email)
    remember_me(user)

    sign_out_all_scopes
    flash[:notice] = t "devise.omniauth_callbacks.success", kind: "Google"
    sign_in_and_redirect user, event: :authentication
  end

  def failure
    redirect_to root_path
  end

  private

  def get_user_from_email(email)
    User.find_by(email:) ||
      Users::Create.call(new_user_attributes).payload
  end

  def new_user_attributes
    {
      name: auth.info.name,
      email: auth.info.email,
      uid: auth.uid,
      provider: auth.provider,
      image_url: auth.info.image
    }
  end

  def auth
    @auth ||= request.env["omniauth.auth"]
  end

  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
