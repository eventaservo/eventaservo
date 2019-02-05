# frozen_string_literal: true

class LikesController < ApplicationController
  def event
    event = Event.by_code(params[:event_code])

    like = event.likes.find_by(user_id: current_user.id)
    if like
      like.destroy
    else
      event.likes.create!(user: current_user)
    end

    redirect_back fallback_location: root_url
  end
end
