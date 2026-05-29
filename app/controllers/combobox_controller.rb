class ComboboxController < ApplicationController
  def users_with_username
    @users =
      if params[:q].blank?
        []
      else
        User.serchi(params[:q]).enabled.limit(20).order(:name)
      end
  end
end
