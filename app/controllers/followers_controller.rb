# frozen_string_literal: true

class FollowersController < ApplicationController
  def event
    event    = Event.find_by_code(params[:event_code])
    follower = event.followers.find_by_user_id(current_user.id)

    if follower
      follower.destroy
    else
      event.followers.create!(user: current_user)
    end

    redirect_back fallback_location: root_url
  end
end
