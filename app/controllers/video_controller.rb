# frozen_string_literal: true

class VideoController < ApplicationController
  def index
    @videoj = ::Video.joins(:evento).order("events.date_start DESC")
    @pagy, @videoj = pagy(@videoj, items: 6)
  end

  def new
    @evento = Event.lau_ligilo(params[:event_code])
  end

  def create
    params.permit(:event_code, :video_link, :title, :description, :image)
    new_video = Video.create(evento: Event.lau_ligilo(params[:event_code]),
      url: params[:video_link],
      title: params[:title].html_safe,
      description: params[:description].html_safe)
    if params[:image].present?
      new_video.bildo.attach(params[:image])
    end

    redirect_to event_url(params[:event_code])
  end

  def destroy
    video = Video.find(params[:id])
    if user_can_edit_event?(user: @current_user, event: video.evento)
      video.destroy
      flash[:success] = "Video forigita"
    else
      flash[:error] = "Vi ne rajtas forigi tiun videon"
    end
    redirect_back fallback_location: root_url
  end
end
