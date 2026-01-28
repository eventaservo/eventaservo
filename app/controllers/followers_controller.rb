# frozen_string_literal: true

class FollowersController < ApplicationController
  before_action :authenticate_user!

  def event
    event = Event.by_code(params[:event_code])
    return redirect_back fallback_location: root_url, alert: "Event not found" unless event

    follower = event.followers.find_by(user_id: current_user.id)

    if follower
      follower.destroy
    else
      event.followers.create!(user: current_user)
    end

    redirect_back fallback_location: root_url
  end
end
