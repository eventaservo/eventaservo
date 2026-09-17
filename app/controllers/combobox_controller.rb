# frozen_string_literal: true

class ComboboxController < ApplicationController
  def users_with_username
    @users =
      if params[:q].blank?
        []
      else
        User.search(params[:q]).enabled.limit(20).order(:name)
      end
  end
end
